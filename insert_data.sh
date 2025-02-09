#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

tail -n +2 games.csv | while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
	WINNER_QUERY=$($PSQL -t -c "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT (name) DO NOTHING RETURNING team_id")
	OPPONENT_QUERY=$($PSQL -t -c "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT (name) DO NOTHING RETURNING team_id")
	TEAM_ID_WINNER=$(echo $WINNER_QUERY | cut -d ' ' -f 1)
	TEAM_ID_OPPONENT=$(echo $OPPONENT_QUERY | cut -d ' ' -f 1)

	if [[ $TEAM_ID_WINNER == "INSERT" ]]; then
		TEAM_ID_WINNER=$($PSQL -t -c "SELECT team_id FROM teams WHERE name='$winner'" | xargs)
	fi

	if [[ $TEAM_ID_OPPONENT == "INSERT" ]]; then
		TEAM_ID_OPPONENT=$($PSQL -t -c "SELECT team_id FROM teams WHERE name='$opponent'" | xargs)
	fi

	if [[ -n $TEAM_ID_OPPONENT && -n $TEAM_ID_WINNER ]]; then
		$PSQL -t -c "INSERT INTO games(
      year,
      round,
      winner_id,
      opponent_id,
      winner_goals,
      opponent_goals
    )
    VALUES(
      $year,
      '$round',
      $TEAM_ID_WINNER,
      $TEAM_ID_OPPONENT,
      $winner_goals,
      $opponent_goals
    )"
	fi

done
