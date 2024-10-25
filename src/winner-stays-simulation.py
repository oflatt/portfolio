# Update simulation to use a line system for opponents
from collections import deque
import numpy as np

import numpy as np
import matplotlib.pyplot as plt

# Set constants for the simulation
num_sessions = 1000    # Number of play sessions
k_max_games = 3      # Maximum games a player can play consecutively
player_counts = range(3, 10)  # Range of player counts (n) to test

# Function to calculate winning probability
def win_probability(skill_i, skill_j):
    return max(min((skill_i - skill_j), 0.5), -0.5) + 0.5

def simulate_session_with_line(n_players, k, games_per_session):
    skills = np.random.normal(0, 1, n_players)  # Players' skills
    games_played = np.zeros(n_players, dtype=int)  # Track games played by each player

    # Initialize players in a queue (line)
    line = deque(range(n_players))
    current_winner = line.popleft()  # First player in line is the initial winner
    consecutive_games = 0  # Track consecutive games for the winner

    for _ in range(games_per_session):
        # Next player in line as the opponent
        opponent = line.popleft()
        win_prob = win_probability(skills[current_winner], skills[opponent])
        games_played[current_winner] += 1
        games_played[opponent] += 1

        if np.random.rand() < win_prob:
            # Current winner wins the game
            line.append(opponent)  # Opponent goes to the back of the line
            consecutive_games += 1
            if consecutive_games >= k:
                # Rotate winner after max consecutive games
                line.append(current_winner)
                current_winner = line.popleft()
                consecutive_games = 0
        else:
            # Opponent wins, they become the new winner
            line.append(current_winner)  # Current winner goes to the back of the line
            current_winner = opponent  # Opponent becomes the new current winner
            consecutive_games = 1

    # Calculate fairness as the max relative difference in games played
    max_games = np.max(games_played)
    min_games = np.min(games_played)
    fairness = max_games / (min_games) 
    return fairness

results_for = {}
std_for = {}

for num_games in [30]:
    for k in range(2, 4):
        values = []
        std_devs = []
        for n in player_counts:
          fairness_results = [simulate_session_with_line(n, k, num_games) for _ in range(num_sessions)]
          values.append(np.mean(fairness_results))
          std_devs.append(np.std(fairness_results))
        results_for[(num_games, k)] = values
        std_for[(num_games, k)] = std_devs



# Plot results with error bars
plt.figure(figsize=(12, 6))
for (num_games, k), values in results_for.items():
    std_devs = std_for[(num_games, k)]
    plt.errorbar(player_counts, values, yerr=std_devs, fmt='o-', label=f'{num_games} games, k={k}')
plt.xlabel('Number of Players (n)')
plt.ylabel('Fairness (Max Ratio of Games Played)')
plt.title('Fairness vs. Number of Players in Winner-Stays System')
plt.legend()
plt.grid(True)
# save the plot to a file, overwriting if it already exists
# delete the plot file if it exists
import os
if os.path.exists("src/documents/fairness-vs-players-line.png"):
    os.remove("src/documents/fairness-vs-players-line.png")
plt.savefig("src/documents/fairness-vs-players-line.png")


plt.show()