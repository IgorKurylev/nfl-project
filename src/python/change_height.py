import pyparsing as pp

fo = open('players.csv','r')
ff = open('players_height.csv','w')

ff.write('nflId,height,weight,birthDate,collegeName,position,displayName'+'\n')
line = fo.readline()
line = fo.readline()

while(line):
   word = pp.commaSeparatedList.parseString(line).asList()
   if '-' in word[1]:
      height = word[1].split('-')
      height = ( (int(height[0])*12) + int(height[1]))
   else: height = word[1]

   ff.write(','.join([word[0],str(height),word[2],word[3],word[4],word[5],word[6]])+'\n')
   line = fo.readline()

fo.close()
ff.close()