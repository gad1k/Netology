import sys

prev_word = None
cur_word = None
cnt = 0

for line in sys.stdin:
    cur_word = line.strip()

    if prev_word is None or prev_word == cur_word:
        cnt = cnt + 1
    else:
        print(prev_word, cnt)
        cnt = 1

    prev_word = cur_word

print(cur_word, cnt)
