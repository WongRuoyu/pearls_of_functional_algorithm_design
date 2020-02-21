# CH2 The maximum surpasser couna
## 目的：
- 设计寻找数组的最大surpasser数的算法，要求复杂度为$O\log(n)$。
## 数组的最大surpasser数
- 一个数组元素的surpasser是指：位于该元素右侧且值比该元素大的元素。
- 一个数组元素的surpasser数是指：该元素的surpasser的个数。
- 数组的最大surpasser个数是指：数组所有元素的surpasser数的最大值。
- 简单实现代码如下。时间复杂度：$O(n^2)$。
- 已经存在复杂度为$O\log(n)$的算法。
```haskell
msc :: Ord a => [a] -> Int
msc xs = maximum [scount z zs| z:zs <- tails xs]
            where scount x xs = length (filter (x <) xs)

tails :: [a] -> [[a]]
tails [] = []
tails (x:xs) = (x:xs): tails xs
```
- 如果能找到满足下面条件，且复杂度为线性$O(n)$的`join`函数:
$$
msc (xs ++ys) = joint (msc xs) (msc ys)
$$
则，`msc`的复杂度满足$T(n)=2T(n/2)+O(n)$，也即`msc`的复杂度为$Olog(n)$。
结论：无法找到符合条件的`join`函数。
## devide and conquer
- 定义
```haskell
table xs = [(z,scount z zs)|z:zs <-tails xs]
msc = maximux.map snd.table
```
- 寻找满足下列条件的`join`函数：
$$
table (xs++ys) =  join (table xs) (table ys)
$$
假设：
```haskell
tails (xs ++ ys) = map (++ys) (tails xs) ++ tails ys
```