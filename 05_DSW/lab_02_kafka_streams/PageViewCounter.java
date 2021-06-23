package com.example.dsw.kafka.streams;

import com.fasterxml.jackson.core.type.TypeReference;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;

import java.time.Duration;
import java.util.Properties;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;

public class PageViewCounter {
    static public class PageView {
        public Long viewtime;
        public String userid;
        public String pageid;
    }

    static public class User {
        public String userid;
        public String regionid;
        public Long registertime;
        public String gender;
    }

    static public class PageViewByGender {
        public String gender;
        public String pageId;
    }

    Topology buildTopology() {
        final StreamsBuilder builder = new StreamsBuilder();

        final KStream<String, PageView> views = builder.stream("pageviews", Consumed.with(Serdes.String(), new JSONSerDe<>(new TypeReference<PageView>() {})));
        final KTable<String, User> users = builder.table("users", Consumed.with(Serdes.String(), new JSONSerDe<>(new TypeReference<User>() {})));

        KStream<String, Long> genderCount = views
                .map((key, pageView) -> new KeyValue<>(pageView.userid, pageView.pageid))
                .join(users, (pageId, user) -> {
                    final PageViewByGender pageViewByGender = new PageViewByGender();
                    pageViewByGender.gender = user.gender;
                    pageViewByGender.pageId = pageId;
                    return pageViewByGender;
                })
                .map((userId, pageViewByGender) -> new KeyValue<>(pageViewByGender.gender, pageViewByGender.pageId))
                .groupByKey()
                .windowedBy(TimeWindows.of(Duration.ofMinutes(1)))
                .count()
                .toStream()
                .map((windowedGender, count) -> new KeyValue<>(windowedGender.key(), count));

        genderCount.to("gender-stats");

        return builder.build();
    }

    public static void main(final String[] args) {
        final Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "dsw-kafka-streams" + UUID.randomUUID());
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, JSONSerDe.class);
        props.put(StreamsConfig.DEFAULT_WINDOWED_KEY_SERDE_INNER_CLASS, JSONSerDe.class);
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, JSONSerDe.class);
        props.put(StreamsConfig.DEFAULT_WINDOWED_VALUE_SERDE_INNER_CLASS, JSONSerDe.class);
        props.put(StreamsConfig.CACHE_MAX_BYTES_BUFFERING_CONFIG, 0);
        props.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 1000);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        PageViewCounter app = new PageViewCounter();

        Topology topology = app.buildTopology();
        System.out.println(topology.describe());

        final KafkaStreams streams = new KafkaStreams(topology, props);
        final CountDownLatch latch = new CountDownLatch(1);

        Runtime.getRuntime().addShutdownHook(new Thread("pipe-shutdown-hook") {
            @Override
            public void run() {
                streams.close();
                latch.countDown();
            }
        });

        try {
            streams.start();
            latch.await();
        } catch (final Throwable e) {
            e.printStackTrace();
            System.exit(1);
        }

        System.exit(0);
    }
}
