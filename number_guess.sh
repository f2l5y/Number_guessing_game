#!/bin/bash

GUESS_NUM=0
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Random number generation
RANDOM_NUM=$(($RANDOM % 1000 + 1))

GUESSER() {
read GUESS
if [[ ! $GUESS =~ ^[0-9]+$ ]];then
        echo "That is not an integer, guess again:"
        GUESSER 
elif [[ $GUESS -lt $RANDOM_NUM ]];then
	echo "It's higher than that, guess again:"
	((GUESS_NUM ++))
        GUESSER 
elif [[ $GUESS -gt $RANDOM_NUM ]];then
	echo "It's lower than that, guess again:"
	((GUESS_NUM ++))
         GUESSER
elif [[ $GUESS -eq $RANDOM_NUM ]];then
	((GUESS_NUM ++))
	INSERT_GAME_PLAYED=$($PSQL "INSERT INTO games(guess_n,user_id) VALUES($GUESS_NUM,$USER_ID);")
	echo "You guessed it in $GUESS_NUM tries. The secret number was $RANDOM_NUM. Nice job!"
fi
}

echo $RANDOM_NUM

echo "Enter your username:"
read USERNAME

# check if user already present

TRIM_USERNAME=$(echo "$USERNAME" | sed -E 's/^ *| *$//g')

RESULT_USER=$($PSQL "SELECT name FROM users WHERE name='$TRIM_USERNAME';")


# if not present
if [[ -z $RESULT_USER ]]; then

RESULT_INSERT="$($PSQL "INSERT INTO users(name) VALUES('$TRIM_USERNAME');")"
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$TRIM_USERNAME';")


echo "Welcome, $TRIM_USERNAME! It looks like this is your first time here."
echo -e "Guess the secret number between 1 and 1000:"

GUESSER

# if present
else 
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$TRIM_USERNAME';")
GAME_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID;")
BEST_GAME=$($PSQL "SELECT guess_n FROM games WHERE user_id=$USER_ID ORDER BY guess_n LIMIT 1;")

echo "Welcome back, $TRIM_USERNAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
echo -e "Guess the secret number between 1 and 1000:"

GUESSER

fi


