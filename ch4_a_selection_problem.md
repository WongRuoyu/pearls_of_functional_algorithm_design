# A Selection Problem
## Intro
- 求两不相交集合的并集($X\cup Y$)中的第`k`个最小元素。
- 在一个集合中，比某元素小的元素个数有`k`个，则该元素为该集合中第`k`小的元素。
- 如果两个集合用有序`List`表示，可实现复杂度为$O(k)$的算法。因为只需要取`k+1`个元素即可，无需全部遍历。
- 如果两集合用有序数组表示，可实现复杂度为$O(Log\vert X \vert+ log \vert Y \vert)$的算法。本pearl的方法。
- 如果用平衡二叉树表示，复杂度与上述方法相同。如何实现？两棵树是无法再线性时间内完成合并的。
- `merge`和`selection`是有关联的。该pearl的目的之一就是要揭示两者之间的关系。是什么？
- 该pearl使用`List`来表示两集合。
## Solution

- 定义：
```haskell
smallest :: (Ord a) => Int -> ([a],[a]) -> a
smallest k (xs,ys) = (union (xs,ys)) !! k
```

- 定义`union`函数如下：
```
union ::(Ord a)=> ([a] , [a]) -> [a]
union (xs,[]) = xs
union ([],ys) = ys
union (x:xs,y:ys) | x < y = x:union(xs,y:ys)
                  | x > y = y:union(x:xs,ys)
```
`union`函数就是将两数组合并的函数，且顺序为从小到大排列。前提是，两参数数据无交集。
- `union`函数是满足交换律的。似乎没什么用。
- 假设`xs`中所有元素都比`vs`中元素小，且`us`中所有元素都比`ys`中元素小，能得到以下结论？：
```haskell
union(xs++ys,us++vs) = (xs++ys) ++ (us++vs) = xs ++ ys ++ us ++ vs
union(xs,us) ++ union(ys,vs)= xs ++ us ++ ys ++ vs
union(union(xs,us),union(ys,vs))=union(xs++us,ys++vs)=xs ++ us ++ys ++ vs
```
中间两项是不满足交换律的。因为根据`++`函数的定义，该函数不满足交换律。

- 暂且假定$union(xs++ys,us++vs)==union(xs,us)++union(ys,vs)$成立。使用$\cup$符号代替`union`函数，得到$(xs++ys)\cup(us++vs)==(xs \cup us)++(ys \cup vs)$。另`xs`和`vs`的关系写为$xs \triangleleft vs$

- 目标是分解：
```
smallest k (xs++[a]++ys,us++[b]++vs)
```
下面先讨论`a<b`的情况。
- 对于$k<\vert xs++ [a] ++us \vert=length(xs) + 1 + length(us)$的情形（k的值小于第一个参数数组长度），有如下结论：
```haskell
smallest k (xs ++ [a] ++ ys,us ++[b]++vs) = smallest k (xs ++ [a] ++ ys,us)
```

- 对于$k > \vert xs++ [a] ++us \vert$的情形（k的值小于第一个参数数组长度），有如下结论：
$$
smallest \quad k \quad (xs++[a]++ys,us++[b]++vs) =
 smallest \quad (k-\vert xs ++[a] \vert) \quad (ys,us ++ [b] ++vs)
$$

- 总结来说，
    - 当`a<b`时，有：
```haskell
smallest k (xs++[a]++ys,us++[b]++vs)
    | k <= p+q = smallest k (xs ++[a]++ys,us)
    | k >  p+q = smallest (k-q-1) (ys,us++[b]++vs)
        where (p,q) = (length xs,length us)
```
    - 当`a>b`时，有：

```haskell
smallest k (xs++[a]++ys,us++[b]++vs)
    | k <= p+q = smallest k (xs,us ++[b]++vs)
    | k >  p+q = smallest (k-q-1) (xs++[a]++ys,vs)
        where (p,q) = (length xs,length us)
```

具体代码如下：

```haskell
smallest :: (Ord a) => Int -> ([a],[a]) -> a
smallest k ([],ws) = ws !! k
smallest k (zs,[]) = zs !! k
smallest k (zs,ws) = 
    case (a<b,k<= p+q) of
        (True,True)   ->  smallest k (zs,us)
        (True,False)  ->  smallest (k-p-1) (ys,ws)
        (False,True)  ->  smallest k (xs,ws)
        (False,False) ->  smallest (k-q-1) (zs,vs)
    where p = div (length zs) 2
          q = div (length ws) 2
          (xs,a:ys) = splitAt p zs
          (us,b:vs) = splitAt q ws
```

- 上述算法中，`smallest`函数的调用次数与`xs`和`ys`的长度成正比。算法似乎不是太正确。
- 当使用数组表示时，由于数组元素的读取为常数复杂度，因此，上述算法的时间复杂度为对数时间。
- 具体代码为：

```
search k (lx,rx) (ly,ry)
    | lx == rx = ya ! k
    | ly == ry = xa ! k
    | otherwise = case (xa ! mx < ya ! my,k<= mx+my) of
                  (True,True)  ->  search k (lx,rx) (ly,my)
                  (True,False) ->  search (k-mx-1) (mx,rx) (ly,ry)
                  (False,True) ->  search k (l,mx) (ly,ry)
                  (False,False) -> search (k-my-1) (lx,rx) (my,ry)
                  where mx= div (lx+rx) 2
                        my= div (ly+ry) 2 

smallestA :: Int ->(Array Int a,Array Int a) -> a
smallest k (xa,ya) = search k (0,m+1) (0,n+1)
                     where (0,m) = bounds xa
                           (0,n) = bounds ya
```

- `listArray` 函数
    - ``listArray ::  Ix i => (i, i) -> [e] -> Array i e``
    - `(i,i)`，分别为数组索引的下界和上界。下届不要求必须从`0`开始。如果两者确定的范围小于或大于``List`元素的个数，那么后者的元素将被截断或引用时抛出异常。

## 结论
- 给出的算法通过`merge`来达到`selection`的目的。
- 存在错误。推导不太严谨，比如`4.2`结论。