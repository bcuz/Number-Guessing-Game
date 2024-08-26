#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read username

user=$($PSQL "select username, games_played, best_game from users where username = '$username'")

if [[ -z $user ]]; then
  echo "Welcome, $username! It looks like this is your first time here."
  insert_user=$($PSQL "insert into users (username) values ('$username');") 
else
  echo $user | while IFS="|" read username games_played best_game
  do
  # l: might be issue here with using 1k as default
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
  done
fi

rand_num=$((1 + $RANDOM % 10))
try=0
echo "Guess the secret number between 1 and 1000:"

while [[ $num != $rand_num ]]
do
  read num
  
  if [[ $num =~ ^[0-9]+$ ]]; then
    ((try=try+1))
  fi 

  if [[ ! $num =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  # if higher
  # these might need to be switched to -gt, etc
  elif [[ $num > $rand_num ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $num < $rand_num ]]; then
    echo "It's higher than that, guess again:"
  # if correct 
  elif [[ $num == $rand_num ]]; then
    echo "You guessed it in $try tries. The secret number was $rand_num. Nice job!"
  fi
done

games=$($PSQL "select games_played from users where username = '$username'")
((games=games+1))
best_game=$($PSQL "select best_game from users where username = '$username'")

# update with new game amount
update_user=$($PSQL "update users set games_played = '$games' where username = '$username'") 

if [[ $try -le $best_game ]]; then
  update_user=$($PSQL "update users set best_game = '$try' where username = '$username'") 
fi