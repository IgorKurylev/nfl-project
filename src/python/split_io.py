import pyparsing as pp

def chek_set():

   fo = open('plays.csv','r')
   line = fo.readline()
   line = fo.readline()
   set = {'RB', 'TE'}

   while(line):
   
      word = pp.commaSeparatedList.parseString(line).asList()
      test = word[11] + ', ' + word[14]
      result = ''.join([i for i in test if not i.isdigit()])
      result = result.replace('"','')
      result = result.replace(' ','')
      result = result.split(',')
      line = fo.readline()

      for i in result:
         set.add(i)

   print(set)

def make_dict(str):
   dict = {}
   test = str
   test = test.replace('"','')
   test = test.replace(' ','')
   test = test.split(',')
   for i in test:
      key = ''.join([j for j in i if not j.isdigit()])
      dict[key] = int( ''.join([j for j in i if j.isdigit()]) )
   return dict

fo = open('plays.csv','r')
ff = open('plays_split.csv','w')

dict_off = {}
dict_def = {}
# {'RB', 'OL', QB', 'LB', 'DB', 'WR', 'TE', 'K', 'P', 'LS', 'DL'}
ff.write('gameId,playId,playDescription,quarter,down,yardsToGo,possessionTeam,playType,yardlineSide,yardlineNumber,offenseFormation,personnelO,defendersInTheBox,numberOfPassRushers,personnelD,typeDropback,preSnapVisitorScore,preSnapHomeScore,gameClock,absoluteYardlineNumber,penaltyCodes,penaltyJerseyNumbers,passResult,offensePlayResult,playResult,epa,isDefensivePI,RB_off,OL_off,QB_off,LB_off,DB_off,WR_off,TE_off,K_off,P_off,LS_off,DL_off,RB_def,OL_def,QB_def,LB_def,DB_def,WR_def,TE_def,K_def,P_def,LS_def,DL_def'+'\n')
line = fo.readline()
line = fo.readline()
personnel = ['0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0']

while(line):
   word = pp.commaSeparatedList.parseString(line).asList()
   
   if word[11]:
      dict_off = make_dict(word[11])
   if word[14]:
      dict_def = make_dict(word[14])

   for i in dict_off:
      if i == 'RB':
         personnel[0] = str(dict_off[i])
      if i == 'OL':
         personnel[1] = str(dict_off[i])
      if i == 'QB':
         personnel[2] = str(dict_off[i])
      if i == 'LB':
         personnel[3] = str(dict_off[i])
      if i == 'DB':
         personnel[4] = str(dict_off[i])
      if i == 'WR':
         personnel[5] = str(dict_off[i])
      if i == 'TE':
         personnel[6] = str(dict_off[i])
      if i == 'K':
         personnel[7] = str(dict_off[i])
      if i == 'P':
         personnel[8] = str(dict_off[i])
      if i == 'LS':
         personnel[9] = str(dict_off[i])
      if i == 'DL':
         personnel[10] = str(dict_off[i])

   for i in dict_def:
      if i == 'RB':
         personnel[11] = str(dict_def[i])
      if i == 'OL':
         personnel[12] = str(dict_def[i])
      if i == 'QB':
         personnel[13] = str(dict_def[i])
      if i == 'LB':
         personnel[14] = str(dict_def[i])
      if i == 'DB':
         personnel[15] = str(dict_def[i])
      if i == 'WR':
         personnel[16] = str(dict_def[i])
      if i == 'TE':
         personnel[17] = str(dict_def[i])
      if i == 'K':
         personnel[18] = str(dict_def[i])
      if i == 'P':
         personnel[19] = str(dict_def[i])
      if i == 'LS':
         personnel[20] = str(dict_def[i])
      if i == 'DL':
         personnel[21] = str(dict_def[i])

   ff.write(','.join([word[0],word[1],word[2],word[3],word[4],word[5],word[6],word[7],word[8],word[9],word[10],word[11],word[12],word[13],word[14],word[15],word[16],word[17],word[18],word[19],word[20],word[21],word[22],word[23],word[24],word[25],word[26],personnel[0],personnel[1],personnel[2],personnel[3],personnel[4],personnel[5],personnel[6],personnel[7],personnel[8],personnel[9],personnel[10],personnel[11],personnel[12],personnel[13],personnel[14],personnel[15],personnel[16],personnel[17],personnel[18],personnel[19],personnel[20],personnel[21]])+'\n')
   line = fo.readline()

fo.close()
ff.close()

