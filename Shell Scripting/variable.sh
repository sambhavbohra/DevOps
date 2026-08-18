# variable="Hello World"
# echo $variable

name="Sambhav"
rollno=10090
comment="Goat"

mkdir variable
cd variable
touch app.log
echo "My name is $name and my rollno is $rollno and my comment is $comment" > app.log
cat app.log
