import Data.Set
import Data.List hiding (insert)
import System.IO
import System.Environment


data Axis = U | L | R | D

instance Show Axis where
  show U = "U"
  show L = "L"
  show R = "R"
  show D = "D"

data Direction = MkDir Int Axis

instance Show Direction where
  show (MkDir l a) = show a ++ show l

parseInstruction :: [Char] -> Direction
parseInstruction ('U' : xs) = MkDir (read xs) U
parseInstruction ('R' : xs) = MkDir (read xs) R
parseInstruction ('L' : xs) = MkDir (read xs) L
parseInstruction ('D' : xs) = MkDir (read xs) D

splitOn :: Eq a => a -> [a] -> [[a]]
splitOn elem vs = reverse $ splitOnAcc elem vs []
  where
    splitOnAcc :: Eq a => a -> [a] -> [[a]] -> [[a]]
    splitOnAcc e [] acc = acc
    splitOnAcc e ls acc = case span (/= e) ls of
                               (word, []) -> word : acc
                               (word, (x : xs)) -> splitOnAcc e xs (word : acc)

parseString :: String -> [Direction]
parseString input = fmap parseInstruction $ splitOn ',' $ input

type Coordinate = (Int, Int)

distance :: Coordinate -> Int
distance (x, y) = abs x + abs y

moveOne :: Axis -> Coordinate -> Coordinate
moveOne L (x, y) = (x - 1, y)
moveOne R (x, y) = (x + 1, y)
moveOne U (x, y) = (x, y + 1)
moveOne D (x, y) = (x, y - 1)

constructGrid :: Coordinate -> [Direction] -> Set Coordinate -> Set Coordinate
constructGrid coord [] state = state
constructGrid coord ((MkDir 0 a) : ds) state = constructGrid coord ds state
constructGrid coord ((MkDir n a) : ds) state =
  let newCoord = moveOne a coord in
      constructGrid newCoord ((MkDir (n - 1) a) : ds) (insert newCoord state)

parseInput :: String -> ([Direction], [Direction])
parseInput input = case lines input of
                        [a, b] -> (parseString a, parseString b)

program :: String -> Int
program input = let (dir1, dir2) = parseInput input
                    grid1 = constructGrid (0, 0) dir1 empty
                    grid2 = constructGrid (0, 0) dir2 empty
                    common = intersection grid1 grid2 in
                    head $ sort (Prelude.map distance (toList common))

testString = "R75,D30,R83,U83,L12,D49,R71,U7,L72\n\
             \U62,R66,U55,R34,D71,R55,D58,R83"

test = "R8,U5,L5,D3\nU7,R6,D4,L4"

main :: IO ()
main = do args <- getArgs
          case args of
               [input] -> putStrLn $ show $ program input
               anythingelse -> putStrLn $ "could not parse " ++ show anythingelse
