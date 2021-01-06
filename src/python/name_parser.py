import sqlite3
import re

# path to database with events
PLAYS_DB_PATH = 'D:\\DS\\project\\test.db'

# path to database to which we will write our points
POINTS_DB_PATH = 'D:\\DS\\project\\points.db'

if __name__ == '__main__':
    conn = sqlite3.connect(PLAYS_DB_PATH)
    to_write = sqlite3.connect(POINTS_DB_PATH)

    c = conn.cursor()
    write_cursor = to_write.cursor()

    write_cursor.execute("""DROP TABLE IF EXISTS Players""")
    write_cursor.execute("""CREATE TABLE Players (name text, points integer, cnt integer)""")

    points = dict()

    c.execute("""SELECT playDescription, playResult
                                    FROM plays""")

    cnt = 0
    for row in c.fetchall():
        m = re.search(r'.*\((\w\.\w+)(;|, (\w\.\w+))*\).*', row[0])
        if m:
            cnt += 1
            if points.get(m.group(1)):
                points[m.group(1)] = (row[1] + points[m.group(1)][0], points[m.group(1)][1] + 1)
            else:
                points[m.group(1)] = (row[1], 1)

            if m.group(3):
                if points.get(m.group(3)):
                    points[m.group(3)] = (row[1] + points[m.group(3)][0], points[m.group(3)][1] + 1)
                else:
                    points[m.group(3)] = (row[1], 1)

    print(f"cnt = {cnt}")
    dict_items = []
    for key, value in points.items():
        dict_items.append((key, value[0], value[1]))

    write_cursor.executemany("""INSERT INTO Players VALUES (?, ?, ?)""", dict_items)

    conn.commit()
    to_write.commit()

    conn.close()
    to_write.close()