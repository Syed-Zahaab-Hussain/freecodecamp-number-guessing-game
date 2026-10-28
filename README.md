# Number Guessing Game

Bash and PostgreSQL game for the freeCodeCamp Relational Databases course. Guess a random integer from 1 to 1000. The database remembers each username, completed game count, and best number of guesses.

## Run

In the freeCodeCamp PostgreSQL environment:

```bash
psql -U postgres < number_guess.sql
chmod +x number_guess.sh
./number_guess.sh
```

The dump recreates `number_guess` and expects the `freecodecamp` PostgreSQL role. On another system, create that role or adjust the connection in `number_guess.sh`.

`schema.sql` records the original database structure; restore the completed database using `number_guess.sql`.
