import sqlite3

# path to database to which we will write additional info about player
POINTS_DB_PATH = 'D:\\DS\\project\\points.db'

# path to database with players
PLAYS_DB_PATH = 'D:\\DS\\project\\test.db'

defenders_positions = ('CB', 'SS', 'MLB', 'OLB', 'FS', 'DE', 'LB', 'ILB', 'DB', 'S', 'NT', 'DT')
attack_positions = ('WR', 'QB', 'TE', 'RB', 'FB', 'HB', )

if __name__ == '__main__':
    points = sqlite3.connect(POINTS_DB_PATH)
    players = sqlite3.connect(PLAYS_DB_PATH)

    c_points = points.cursor()
    c_players = players.cursor()

    # launch if running first time
    # c_players.execute("""ALTER TABLE players
    #                              ADD COLUMN points;""")
    # c_players.execute("""ALTER TABLE players
    #                          ADD COLUMN cnt;""")

    c_points.execute("""SELECT name FROM Players""")
    players_dict = dict()

    coincidences = 0
    for points_row in c_points.fetchall():
        c_players.execute("""SELECT displayName, 
                             substr(displayName, 1, instr(displayName, ' ') - 1) as first_name, 
	                         substr(displayName, instr(displayName, ' ') + 1, length(displayName) - instr(displayName, ' ') + 1) as second_name,
	                         position
                             FROM players
                             WHERE second_name = """ + "'" + points_row[0][2:] + "'" + ";")

        for players_row in c_players.fetchall():
            if players_row[1].startswith(points_row[0][0]):
                if players_dict.get(players_row[0]):
                    if players_row[3] in defenders_positions:
                        coincidences += 1
                        if coincidences == 4:
                            print("In dict: ", players_row[0], players_dict[players_row[0]])
                            print("critical coincidence number!!!")
                            exit(1)
                else:
                    if players_row[3] in defenders_positions:
                        players_dict[players_row[0]] = points_row[0]

    c_players.execute("""SELECT displayName FROM players""")
    for players_row in c_players.fetchall():
        if players_dict.get(players_row[0]):
            c_points.execute("""SELECT name, points, cnt
                                FROM Players
                                WHERE name = """ + "'" + players_dict[players_row[0]] + "'" + ";")

            points_row = c_points.fetchall()[0]
            ex_str = """UPDATE players
                                             SET points = """ + str(points_row[1]) + """ ,
                                                 cnt = """ + str(points_row[2]) + """
                                             WHERE displayName = """ + '"' + players_row[0] + '"' + """;"""
            c_players.execute(ex_str)

    print(players_dict)
    print(len(players_dict))

    points.commit()
    players.commit()

    points.close()
    points.close()