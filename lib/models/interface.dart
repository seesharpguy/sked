import 'game_models.dart';

abstract class IHavePlayers {
  List<Player> get players;
}

abstract class IHaveGame {
  Game get game;
}

abstract class IHaveTurns {
  List<Turn> get turns;
}
