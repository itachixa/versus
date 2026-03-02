List<Map<String, String>> generateMatches(List<String> teams) {
  List<Map<String, String>> matches = [];

  for (int i = 0; i < teams.length; i++) {
    for (int j = i + 1; j < teams.length; j++) {
      matches.add({
        "teamA": teams[i],
        "teamB": teams[j],
      });
    }
  }
  return matches;
}