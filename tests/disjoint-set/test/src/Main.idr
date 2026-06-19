module Main

import System
import Tester
import Tester.Runner

import DisjointSet

tests : List Test
tests =
  [ test "no unions leaves every element in its own set" $ do
      assertEq 5 (countComponents 5 [])
  , test "chained unions merge everything into one set" $ do
      assertEq 1 (countComponents 4 [(0, 1), (2, 3), (0, 2)])
  , test "disjoint groups are counted separately" $ do
      assertEq 3 (countComponents 6 [(0, 1), (1, 2), (3, 4)])
  ]

main : IO ()
main = do
  success <- runTests tests
  if success
     then putStrLn "All tests passed"
     else exitFailure
