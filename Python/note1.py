#__________________________ only trained codes from deep of my pc _______________________________________#



# try:
#     x = int(input(":enter num :"))
#     print(x)
# except :
#     x = 0
#     print("error")
# print(x)


# a = int(input("A:"))
# b = int(input("B:"))

# op = input("op:")


# match op:# to compare op
#     case "+":# what to compare
#         print(a+b)
#     case "-":
#         print(a-b) 
#     case "/":
#         print(a/b)
#     case "*":
#         print(a*b)
#     case _:# Deafualt (else)
#         print("not correct")

# import datetime
# import os


# while True:
#     print(datetime.datetime.now())
#     os.system("cls")
#     for i in range(10):
#         print(i*"-",end="")


print("----main start ----")
import threading
import time

def my_func(n):
    print(f"th  {n} start")
    time.sleep(3)
    print(f"th {n} finished")

#thread = threading.Thread(target=my_func,args=[1])
threads = [threading.Thread(target=my_func,args=[i]) for i in range(10)]
for th in threads:
    th.start()
# for th in threads:
#     th.join()

#thread.start()# start second way

#thread.join()#wain to join up thread






print("----main finfished ----")
