
module Main

import Data.SortedSet

data Axis = U | L | R | D

Show Axis where
  show U = "U"
  show L = "L"
  show R = "R"
  show D = "D"

record Direction where
  constructor MkDir
  length : Int
  axis : Axis

Show Direction where
  show (MkDir l a) = show a ++ show l

partial
parseInstruction : List Char -> Direction
parseInstruction ('U' :: xs) = MkDir (cast $ pack xs) U
parseInstruction ('R' :: xs) = MkDir (cast $ pack xs) R
parseInstruction ('L' :: xs) = MkDir (cast $ pack xs) L
parseInstruction ('D' :: xs) = MkDir (cast $ pack xs) D
parseInstruction _ = ?instructionError

parseString : String -> List Direction
parseString input = map parseInstruction $ splitOn ',' $ unpack input

Coordinate : Type
Coordinate = (Int, Int)

distance : Coordinate -> Int
distance (x, y) = x + y

coordsFrom : Direction -> Coordinate -> List Coordinate
coordsFrom (MkDir length L) (i, j) = let range = [1..(length)] in map (\x => MkPair (i-x) j) range
coordsFrom (MkDir length R) (i, j) = let range = [1..(length)] in map (\x => MkPair (i+x) j) range
coordsFrom (MkDir length D) (i, j) = let range = [1..(length)] in map (\y => MkPair i (j-y)) range
coordsFrom (MkDir length U) (i, j) = let range = [1..(length)] in map (\y => MkPair i (j+y)) range

move : Direction -> Coordinate -> Coordinate
move (MkDir length U) (a, b) = (a, b + length)
move (MkDir length L) (a, b) = (a - length, b)
move (MkDir length R) (a, b) = (a + length, b)
move (MkDir length D) (a, b) = (a, b - length)

constructGrid : Coordinate -> List Direction -> SortedSet Coordinate -> SortedSet Coordinate
constructGrid coord [] state = state
constructGrid coord (d :: ds) state =
  let coords = coordsFrom d coord
      newState = foldl (\set, key => insert key set) state coords in
      constructGrid (move d coord) ds newState

parseInput : String -> (List Direction, List Direction)
parseInput input = case lines input of
                        [a, b] => (parseString a, parseString b)
                        _ => ?error

program : String -> Maybe Int
program input = let (dir1, dir2) = parseInput input
                    grid1 = constructGrid (0, 0) dir1 empty
                    grid2 = constructGrid (0, 0) dir2 empty
                    common = intersection grid1 grid2 in
                    head' $ sort (map distance (SortedSet.toList common))

main : IO ()
main = do [_, input] <- getArgs
          case program input of
               Just result => putStrLn (show result)
               Nothing => putStrLn "no result"
