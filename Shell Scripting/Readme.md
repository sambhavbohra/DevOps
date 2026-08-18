# Shell Scripting - Variables and Input

This folder contains examples of variables and user input in Bash.

## 1. Variable example

File: variable.sh

```bash
name="Sambhav"
rollno=10090
comment="Goat"

mkdir variable
cd variable
touch app.log
echo "My name is $name and my rollno is $rollno and my comment is $comment" > app.log
cat app.log
```

### Output
```bash
My name is Sambhav and my rollno is 10090 and my comment is Goat
```

### Screenshot
![Variable Output](screenshots/variableoutput.png)

---

## 2. Input example

File: input.sh

```bash
read -p "Enter your name: " name
read -p "Enter your rollno: " rollno
read -p "Enter your comment: " comment

echo "My name is $name and my rollno is $rollno and my comment is $comment"
```

### Example interactive output
```bash
Enter your name: Sam
Enter your rollno: 101
Enter your comment: Good
My name is Sam and my rollno is 101 and my comment is Good
```

### Screenshot
![Input Output](screenshots/input_output.png)

---

## 3. Task example

File: task.sh

```bash
mkdir task && cd task

touch user.log
echo "Todays date is $(date)" > user.log
echo "Hostname is $(hostname)" >> user.log
echo "user is $(whoami)" >> user.log
cat user.log

touch process.log
echo "Process is $(ps)" > process.log
cat process.log

read -p "Enter your name: " name
read -p "Enter your rollno: " rollno
read -p "Enter your comment: " comment

touch personal.log
echo "My name is $name and my rollno is $rollno and my comment is $comment" > personal.log
cat personal.log
```

### Example output
```bash
Todays date is Tue Aug 18 2026 12:00:00 IST
Hostname is MacBook-Pro
user is sammy
Process is ...
My name is Sam and my rollno is 101 and my comment is Good
```

### Screenshot
![Task Output](screenshots/task%20output.png)

Folder: screenshots/
