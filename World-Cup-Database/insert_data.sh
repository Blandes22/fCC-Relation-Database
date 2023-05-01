#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

update_teams () {
  TEAM_NAME=$1
  CHECK=$($PSQL "SELECT 1 FROM teams WHERE name='$TEAM_NAME'")
  if [[ $CHECK != 1 ]]
  then
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$TEAM_NAME')")"
  fi
}

# clean up table for data entry
echo "$($PSQL "TRUNCATE TABLE teams CASCADE")"
echo "$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")"
echo "$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")"

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS;
do
  if [[ $YEAR != 'year' ]]
  then
    # update teams table
    update_teams "$WINNER"
    update_teams "$OPPONENT"
    
    # update games table
    echo "$($PSQL "
      INSERT INTO games(year, round, winner_id, opponent_id, 
      winner_goals, opponent_goals)
      VALUES($YEAR, '$ROUND', 
      $($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'"), 
      $($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'"), 
      $WINNER_GOALS, $OPPONENT_GOALS)")"
  fi
done