// Simple rules logic script
#define SERVER_ONLY

array<string> respawnPlayerList;

uint difficultyLevel;

void onInit(CRules@ this) {
  difficultyLevel = 0;
  return;
}

void onPlayerRequestSpawn(CRules@ this, CPlayer@ player) {
	Respawn(this, player);
  player.getBlob().Tag("survivorplayer");
}

CBlob@ Respawn(CRules@ this, CPlayer@ player) {
	if (player !is null) {
		// remove previous players blob
		CBlob @blob = player.getBlob();

		if (blob !is null) {
			CBlob @blob = player.getBlob();
			blob.server_SetPlayer(null);
			blob.server_Die();
		}

		CBlob @newBlob = server_CreateBlob("builder", 0, getSpawnLocation(player));
		newBlob.server_SetPlayer(player);
		return newBlob;
	}
	return null;
}

Vec2f getSpawnLocation(CPlayer@ player) {
	return rightConner(8);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData) {
  MessageBox("respawn in 10 sec", false);
  respawnPlayerList.insertLast(victim.getUsername());
}

void onTick(CRules@ this) {
  // respawn player in a certain duration
  if (getGameTime() % 500 == 0 && respawnPlayerList.length != 0) {
    for (uint i = 0; i < respawnPlayerList.length; i++) {
      onPlayerRequestSpawn(this, getPlayerByUsername(respawnPlayerList[i]));
    }
    respawnPlayerList.resize(0);
  }

  // game end rule
  if (getGameTime() % 100 == 0 && getGameTime() > 1000 && getPlayerCount() != 0 && respawnPlayerList.length == getPlayerCount()) {
    this.SetTeamWon(1);
    this.SetCurrentState(GAME_OVER);
    this.SetGlobalMessage("No survivors are left. You died on point "+ getGameTime() +".");
    LoadNextMap();
    this.SetGlobalMessage("");
  }

  // spawn zombies
  if (getGameTime() % 200 == 0 && (getMap().getDayTime()>0.8 || getMap().getDayTime()<0.1)) {
    difficultyLevel++;
    array<int> zombieList = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
    array<int> skyKiller = {2, 3, 9};
    array<int> bosses = {0, 4, 10, 16};
    array<int> destroyer = {5, 6, 12};
    array<int> farmer = {1, 7, 8, 11, 13, 14, 15};
    if (true) spawnZombie(farmer);
    if (difficultyLevel > 100 || difficultyLevel % 10 == 0) spawnZombie(skyKiller);
    if (difficultyLevel > 100 || difficultyLevel % 5 == 0) spawnZombie(destroyer);
    if (difficultyLevel > 500) spawnZombie(zombieList);
  }
  return;
}

funcdef void EFFECT ();
void updateWhen (int timeInterval, bool cond, EFFECT @e) {
  if (getGameTime() % 500 == 0 && cond) e;
}

void spawnZombie(array<int> zs) {
  int zp = 8;
  Vec2f zombiePlace = leftConner(zp);
  array<string> zombieTypes =
    { "abomination" // 0
    , "catto" // 1
    , "gasbag" // 2
    , "greg" // 3
    , "horror" // 4
    , "pankou" // 5
    , "pbanshee" // 6
    , "pbrute" // 7
    , "pcrawler" // 8
    , "pgreg" // 9
    , "phellknight" // 10
    , "skeleton" // 11
    , "wraith" // 12
    , "zbison" // 13
    , "zchicken" // 14
    , "zombie" // 15
    , "zombieKnight" // 16
    };
  for (uint i = 0; i < zs.length; i++) {
    server_CreateBlob(zombieTypes[zs[i]], -1, zombiePlace);
  }
}


Vec2f leftConner(int zp) {
  Vec2f col;
  getMap().rayCastSolid( Vec2f(zp*8, 0.0f), Vec2f(zp*8, getMap().tilemapheight*8), col);
  col.y-=16.0;
  return col;
}

Vec2f rightConner(int zp) {
  Vec2f col;
  getMap().rayCastSolid( Vec2f((getMap().tilemapwidth-zp)*8, 0.0f), Vec2f((getMap().tilemapwidth-zp)*8, getMap().tilemapheight*8), col);
  col.y-=16.0;
  return col;
}
