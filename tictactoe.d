import std.stdio;
import std.array;
import std.conv;
import core.exception;

// TODO: make whole game in a class? + some improvements

class PositionAlreadyUsed : Exception { this(string message) { super(message); } }
class PositionNotInRange : Exception { this(string message) { super(message); } }

struct Player {
    string name;
    string character;

    private bool checkValidMove(const string[3][3] board, int[] pos) {
        try {
            return board[pos[0] - 1][pos[1] - 1] == "-";
        } catch (ArrayIndexError e) {
            throw new PositionNotInRange("PNIR");
        }
    }

    void makeMove(ref string[3][3] board, int[] pos) {
        if (checkValidMove(board, pos))
            board[pos[0] - 1][pos[1] - 1] = character;
        else
            throw new PositionAlreadyUsed("PAU");
    }
}

int checkFreeSpaces(const string[3][3] board) {
    int freeSpaces = 9;
    foreach (row; board) 
        foreach (c; row) 
            if (c != "-") 
                --freeSpaces;

    return freeSpaces;
}

void printBoard(const string[3][3] board) {
    foreach (l, c; board) {
        write(" ");

        foreach (k, v; c)
            write(v, (k < 2) ? " | " : "\n");

        if (l < 2)
            writeln("---|---|---");
    }

    write("\n");
}

void switchPlayer(ref Player currentPlayer, Player p1, Player p2) {
    if (currentPlayer == p1)
        currentPlayer = p2;
    else if (currentPlayer == p2)
        currentPlayer = p1;
}

bool checkWin(const string[3][3] board) {
    // vertical and horizontal win
    for (int i = 0; i < 3; ++i) {
        if (board[i][0] != "-" && (board[i][0] == board[i][1]) && (board[i][1] == board[i][2]))
            return true;
        if (board[0][i] != "-" && (board[0][i] == board[1][i]) && (board[1][i] == board[2][i]))
            return true;
    }

    // diagonal win
    if (board[0][0] != "-" && (board[0][0] == board[1][1]) && (board[1][1] == board[2][2]))
        return true;
    if (board[0][2] != "-" && (board[0][2] == board[1][1]) && (board[1][1] == board[2][0]))
        return true;

    // no win
    return false; 
}

enum PlayerChar { PLAYER_1 = "X", PLAYER_2 = "O" }

void main() {
    string[3][3] board = "-";

    Player p1 = Player("Player 1", PlayerChar.PLAYER_1);
    Player p2 = Player("Player 2", PlayerChar.PLAYER_2);
    assert(p1.name != p2.name, "names of the players must be different");

    Player currentPlayer = p1;
    bool win;

    while (!win && checkFreeSpaces(board) > 0) {
        printBoard(board);

        write(currentPlayer.name, "'s move (e.g. 1, 2) > ");
        int[] playerMove = to!(int[])(split(readln())); // e.g. 1 2 -> [ 1, 2 ]

        try {
            currentPlayer.makeMove(board, playerMove);
        } catch (PositionNotInRange e) {
            writeln("\nPlease use a valid position.\n");
            continue;
        } catch (PositionAlreadyUsed e) {
            writeln("\nThis position is already used. Choose another one.\n");
            continue;
        }

        if (checkWin(board))
            win = true;
        else 
            switchPlayer(currentPlayer, p1, p2);

        write("\n");
    }

    printBoard(board);
    
    if (win)
        writeln("Congratulations ", currentPlayer.name, ", you won!");
    else
        writeln("It's a tie :/");

}