import sys

for i, line in enumerate(sys.stdin):
    if i == 0:
        continue

    for word in line.strip().split(",")[0].split(" "):
        print(word)
