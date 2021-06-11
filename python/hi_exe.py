# work in progress
# Author: Eugenio Gonzalez
import os

def main ():
    user=os.getlogin() # get the logged user
    DESKTOP_PATH = f"C:\\Users\\{user}\\Desktop\\"
    with open(DESKTOP_PATH + 'Hi.txt', 'w') as file: # create the file
    file.write("""Hi!
    Dont worry, im not dangerous... yet.
    """)

if __name__ == "__main__":
    main()
