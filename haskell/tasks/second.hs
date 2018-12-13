create list of all tuples with 2 elements from the given list 
getAllTuples [1, 2, 3] -> [(1, 1), (1, 2), (1, 3), (2, 2), (2, 3), (3, 3)]
                                            
create list of all tuples where the elements in the tuple are sides 
of a right triangle 
isRightTriange [1, 2, 3, 4, 5, 6] -> [3, 4, 5]

myDrop -> drop the first n elements and return the rest
myDrop [1, 2, 3, 4, 5] 2 -> [3, 4, 5]

zip the elements from 2 lists first with first, second with second... 
myZip [1, 2, 3] [2, 5, 7] -> [(1, 2), (2, 5), (3, 7)]

returns the sum of the elements in a list
sumElems [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] -> 55

checks if element is in the list
myMember [1, 2, 3, 4, 5] 3 -> True

checks if elements in a list are sorted
isSorted [1, 2, 4, 5, 6] -> True
isSorted [3, 2, 4] -> False

