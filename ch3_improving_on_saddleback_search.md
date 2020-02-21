# Improving on saddleback search
## Intro
- 设计一个`invert` 函数，该函数接收两个参数：`f`和`z`：
```haskell
f :: (Num a)=> a ->a->a->a
z :: (Num a)=> a
```
其中，函数`f`单调递增。
满足下列条件：
```haskell
invert f z = [(x,y)|f(x,y)==z]
```
- 从下面的分析可看出，题目中，"f is strictly increasing in each argument"的假设不太严谨的。
## 解题思路
### Jack思路的缺点
- Jack提出`f(x,y)=z,implies x <= z`。该推论错误。反例：`f(x,y)=0.5*x+y`。该函数对`x`单调递增，但显然无法得到Jack的推论。
- 正确的假设是，在f为直线的情况下，f的斜率大于1。
- 该思路已经确定了搜索空间为直角坐标系中由(0,0)和(z,z)两确定的正方形区域内。
- Theo的思路是建立在Jack的思路之上的，也是错误的。其正确的前提是：只考虑直线的情况下，x和y的斜率（系数）都大于1。该pear之后的讨论都建立在该前提之下。
### Theo的思路
-  Theo在Jack思路的基础上进一步缩小了解空间的范围。
-  在Jack的前提下，有：
$$
f(x,y)>f(x,0)>x;
f(x,y)>f(y,0)>y
$$
但是，得不到$f(x,y)>x+y$。后续讨论都建立在该论断之上，先默认它成立。
-  根据上面的结论，根据函数`f`的单调性，可知，该函数在搜索区域上的最小值为`f(0,0)`,最大值为`f(z,z)`。其搜索区域可进一步缩小为由直线（包含）下方的区域，是三角形。此时，解为：
```haskell
invert f z = [x<-[0,z-f(0,0)],y<-[0,z-x-f(0,0)],f x y ==z]
```
### Anne的思路
- 前面的思路都是二维平面下的一半思路：按照变量递增的方向搜索。Anne的思路是`saddleback`搜索。其思路是，从左上角$(u,v)$向右下角$(z,0)$搜索。写成一般形式就是：
$$
find \quad (u,v) \quad f \quad z = [(x,y)|x<-[u..z],y<-[v,v-1..0],f x y == z]
$$。
上式的搜索空间，是由上述两个顶点确定的矩形。如此的话，要求解的`invert`函数就应满足：
$$
invert \quad f \quad  z = find \quad (0,z) \quad f \quad z
$$

- 接下来的工作，就是根据该通用形式作模式匹配。匹配的依据就是$f(x,y)$的值和$z$的关系。根据值的大小关系来调整搜索的走向，将搜索的路线控制在$f(x,y)==z$这条线上。
- 从递归的调用也看出搜索的方向。在该条件下，f的函数值大于给定值z。其候选方向有两个，可以分别按x或y方向减小。但由于是从左上角向右下角搜索。所以，只能是在y方向上递减。若果在x方向上递减，即调用`find (u-1,v) f z`那么，就是往左边走了。可能会丢失一部分解。
- 同理。在`f`的值小于`z`时，应该增大变量的值。此时，代码增加的是变量`x`的值。道理和减小`y`的值的情形是一致的。
- 如果在`f`的值等于`z`，此时按照对角线方向(右下角)前进。
- find 函数通过第一个参数$(u,v)$就是搜索的起点；对于搜索的方向，则具体体现在模式匹配的代码中。起动一定是和方向对应的，否则就得不到正确的解。
- 具体代码如下：
```Haskell
invert f z = find (0,z) f z
find (u,v) f z | u>z || v<0 = []
               | zl < z = find (u+1,v) f z
               | zl == z = (u,v) : find (u+1,v+1) f z
               | zl >z = find (u,v-1) f z
                where zl = f (u,v)

```

- 进一步缩小搜索范围。令：
$$
m = max \{y | f(0,y) ==z,y \in [0,z]\}
;
n = max \{x | f(x,0) ==z,x \in [0,z]\}
$$
```haskell
m = maximum (filter (\y->f(0,y)==z) [0..z])
n = maximum (filter (\x->f(x,0)==z) [0..z])
```
则，根据`f`递增的性质，可将搜索范围进一步缩小至$(n,m)$和$(0,0)$确定的矩形中。
这个方法得到的范围，也适用于Jack和Theo的方法。
- 相应地，此时从左上角开始搜索，有：
```haskell
invert f z = find (0,m) f z
```
- 用上面方法找到`m`和`n`效率太低，使用二分查找法。"the curcial point..."这段有点懵。但是作者想要说明的问题就是，可以使用二分法查找`m`。因为二分法查找的前提是，数组是有序的。这个本问题的大前提：函数`f`是递增的，正好吻合。根据二分查找的套路：其代码实现如下：

```haskell
bsearch :: (Num a)=> (a->a->a) -> (a,a) -> a
bsearch g (a,b) z | a + 1 == b = a
                  | g m <= z  = bsearch g (m,b) z
                  | otherwise = bearch g (a,m) z
                    where m = (a+b) div 2

m = bsearch (\y->f 0 y) (-1,z+1) z
n = bsearch (\x->f x 0) (-1,z+1) z
```
上述`m`和`n`的求法中，相当于假定了$f(-1,0)=0$和$f(0,-1)=0$。否则，搜索范围的下限，就不应该是`-1`。因为`f`的具体实现未知，所以作此假设。

- 至此，`invert`函数的具体形式可表示为：
```haskell
bsearch ::(Integral a)=> (a->a)->(a,a)->a->a
bsearch g (l,h) z | (l + 1) == h = l
                  | g m <= z  = bsearch g (m,h) z
                  | otherwise = bsearch g (l,m) z
                     where m = div (l+h) 2

theoSP3 ::(Integral a)=> (a->a->a)->a->[(a,a)]
theoSP3 f z = find (0,m) f z 
                where m = bsearch (f 0) (-1,z+1) z                  
```
该算法执行`f`的次数约为$(2logz+m+n)$，其中：$logz$是二分查找的复杂度。
- 为什么是2倍？为什么是$m+n$，而不是$m*n$。$m+n$是因为模式匹配的原因，代替了迭代？最优情况下，只沿一个方向查找，次数为$2logz + min\{m,n\}$。再者，$m$和$n$是极有可能远小于$z$的，此时，算法的时间复杂度为$O(lgz)$（忽略其系数，忽略$m$和$n$影响）。
- $2lgz$是因为，在计算`m`和`find`时，都需要调用`f`函数，所以是两倍关系。

### Mary思路
- 类似于二分查找，利用矩形对角线上的中点将解空间分隔成四个小矩形。根据对角线上的函数值确定下一步的搜索空间，每次可以丢弃四个小矩形中的一个。缺点是，在确定可以丢弃一部分搜索空间后，剩下的空间就不是矩形了，成为`L`形。这脑洞的确可以。
- 条件$f(p,q)<z<f(p+1,q)$很关键。它说明了，若沿`x`轴增大方向搜索，`f`值将大于`z`，也就是排除了这个方向上的可能性，缩小了搜索 空间。将`L`形的搜索空间进一步缩小至左上和右下两个空间。右上方向是两变量都增大的方向，`f`的值当然也增大。解空间的确定都是按照两变量一个增大，另一个减小的方向搜索的。
- 具体代码如下：
```haskell
findD :: (Integral a) => (a,a) -> (a,a) -> (a->a->a) ->a -> [(a,a)]
findD (u,v) (r,s) f z
       | u > r || v<s   = []
       | (v-s) <= (r-u) = rfind (bsearch (\x -> f x q) (u-1,r+1) z )
       | otherwise      = cfind (bsearch (\y -> f p y) (s-1,v+1) z )
          where p = div (u+r) 2
                q = div (s+v) 2
                rfind p = (if (f p q)==z then (p,q):(findD (u,v) (p-1,q+1) f z) else (findD (u,v) (p,q+1) f z) ) ++ (findD (p+1,q-1) (r,s) f z) 
                cfind q = (findD (u,v) (p-1,q+1) f z) ++ (if (f p q)==z then (p,q):(findD (p+1,q-1) (r,s) f z) else (findD (p+1,q) (r,s) f z) )


marySP3 f z = findD (0,m) (n,0) f z
              where m = bsearch (f 0) (-1,z+1) z
                    n = bsearch (\x-> f x 0) (-1,z+1) z
```

- 可以证明上述算法复杂度为$T(m,n)= O(mlg(n/m))$渐进趋近$A(m,n)=\Omega(mlog(n/m))$。后者复杂度的证明略去。有空再补吧。

## 结语
- 有时先进行理论分析，得出复杂度的上、下限，也是知道算法设计的方法。可以看出现在算法是否还有改进空间。
- 函数式算法设计多采用分治算法思路。因为分解问题为一系列与原问题同构的小问题，可以使用递归的数据结构和思路。而函数式范式更善于利用递归的数据结构。
- 解题的思路不一定要越来越具体。有时将问题泛化为一般问题反而会有更好的效果。