#FIZZBUZZ with tulip

tup = "FIZZ", "BUZZ",
print(tup)
for q in range(30):
	i=q+1
	if i % 5 == 0:
		if i % 3 == 0:
			print(tup[0] + tup[1])
		else:
			print(tup[1])
	elif i % 3 == 0:
		print(tup[0])
	else:
		print(str(i))
			
			
 
