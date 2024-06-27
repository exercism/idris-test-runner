module Main

import System
import Tester
import Tester.Runner

import HelloWorld

tests : List Test
tests = 
  [ test "hello should have correct value" $ do
      assertEq "Goodbye, Mars!" hello
  , test "version should have correct value" $ do
      assertEq "1.0.0" version
  ]

main : IO ()
main = do
  success <- runTests tests
  if success
     then putStrLn "All tests passed"
     else exitFailure

