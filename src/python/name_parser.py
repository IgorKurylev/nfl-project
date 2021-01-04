import sqlite3
import re

if __name__ == '__main__':
    conn = sqlite3.connect('D:\\DS\\project\\test.db')
    c = conn.cursor()

    c.execute("""SELECT playDescription
                                    FROM plays""")

    cnt = 0
    for row in c.fetchall():
        print(row[0])
        m = re.search('.*\((\w\.\w+)\).*', row[0])
        if m:
            cnt += 1
            print(m.group(1))
        else:
            print("No matches")
        if cnt == 5:
            break

    print(f"cnt = {cnt}")

    conn.commit()
    conn.close()