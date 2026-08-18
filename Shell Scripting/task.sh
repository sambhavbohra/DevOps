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
