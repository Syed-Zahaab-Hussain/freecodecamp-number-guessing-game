#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -X -t --no-align -c"
SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo "Enter your username:"
read -r USERNAME || exit 0
USERNAME_SQL=${USERNAME//\'/\'\'}
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username = '$USERNAME_SQL'")
if [[ -z $USER_INFO ]]; then
  USER_ID=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME_SQL') RETURNING user_id" | head -n 1)
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  IFS='|' read -r USER_ID GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
GUESSES=0
while read -r GUESS
do
  ((GUESSES += 1))
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  # Normalize leading zeros and compare long values without overflowing Bash integers.
  NORMALIZED=$(printf '%s' "$GUESS" | sed 's/^0*//')
  NORMALIZED=${NORMALIZED:-0}
  if [[ ${#NORMALIZED} -gt 4 ]] || (( 10#$NORMALIZED > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  elif (( 10#$NORMALIZED < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  else
    $PSQL "UPDATE users SET games_played = games_played + 1, best_game = CASE WHEN best_game IS NULL OR best_game > $GUESSES THEN $GUESSES ELSE best_game END WHERE user_id = $USER_ID" >/dev/null
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    exit 0
  fi
done
