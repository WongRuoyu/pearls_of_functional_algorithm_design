import Data.Array
import Data.List

minfree :: [Int] -> Int
minfree = search.checklist

search :: Array Int Bool -> Int
search= length.(takeWhile id).elems

-- accumArray can build an arrays by processing the association list from left to right, 
--      combining entries and values into new entries using the accumulating function(the first argument).
--      对于(0,n)范围中，没有出现的索引，accumArray使用default参数(第二个参数)作为该索引的值。
--          ie. accumArray (||) False (0,3) [(1,True),(3,True),(1,False)] produces:
--               array (0,3) [(0,False),(1,True),(2,False),(3,True)]
--               where:
--                  第一项，由于索引‘0’未出现在关联表中，所以它的值由默认值‘False’填充；
--                  第二项，由于关联表中有两个元素的索引都是'1',那么，生成的数组中，该索引对应的值由关联表中的‘accumulate function’参数，也就是第一个数，运算得到。由于$False || True=True\$，所以，结果数组中，'1'对应的值为'True'。
--                  第三项和第一项情况相同。
--                  第四项，由于无重复的索引，所以直接由关联表中得到。
checklist :: [Int] -> Array Int Bool
checklist xs = accumArray (||) False (0,n) (zip (filter (<= n) xs) (repeat True))
                    where n = length xs

-- minfree2 will fail, 因为n可能会小于xs中某个元素，造成accumArray调用失败。
minfree2 :: [Int] -> Int
minfree2 = search.checklist2
checklist2 :: [Int] -> Array Int Bool
checklist2 xs = accumArray (||) False (0,n) (zip xs (repeat True))
                    where n = length xs


minfree3 = search.checklist3
checklist3 :: [Int] -> Array Int Bool
checklist3 xs = accumArray (||) False (0,mv) (zip xs (repeat True))
                    where mv=maximum xs


sortL :: [Int]->[Int]
sortL xs = (filter (>0)).elems $ array
                where array = accumArray (+) 0 (0,mv) [(a,a)|a<-xs]
                      mv = maximum xs



