
msc :: Ord a => [a] -> Int
msc xs = maximum [scount z zs| z:zs <- tails xs]
            where scount x xs = length (filter (x <) xs)

tails :: [a] -> [[a]]
tails [] = []
tails (x:xs) = (x:xs): tails xs