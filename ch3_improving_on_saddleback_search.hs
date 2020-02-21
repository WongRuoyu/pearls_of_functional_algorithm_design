import Numeric.Natural

f1 :: (Num a) => a->a->a
f1 x y = 2*x + 2*y

gboundy :: (Num a,Ord a,Enum a)=> (a->a->a)-> a -> a
gboundy f z = maximum (filter (\v-> (f v 0) == z) [0..z])
gboundx f z = maximum (filter (\v-> (f 0 v) == z) [0..z])

boundx = gboundx f1
boundy = gboundy f1


jackSP :: (Num a,Eq a,Enum a)=>(a->a->a)->a->[(a,a)] 
jackSP f z = [(x,y)|x<-[0..z],y<-[0..z],(f x y) == z]
jackS = jackSP f1


theoSP :: (Num a,Eq a,Enum a)=>(a->a->a)->a->[(a,a)] 
theoSP f z = [(x,y)|x<-[0..z],y<-[0..z-x],(f x y) == z]
theoS = theoSP f1

theoSP2 f z = [(x,y)|x<-[0..mvx],y<-[0..mvy-x],(f x y) == z]
                where mvx = boundx z
                      mvy = boundy z
theoS2 = theoSP2 f1

find :: (Num a,Ord a,Enum a) =>(a,a) -> (a->a->a) ->a -> [(a,a)]
find (u,v) f z | u>z || v<0 = []
               | zl < z = find (u+1,v) f z
               | zl == z = (u,v) : find (u+1,v+1) f z
               | zl >z = find (u,v-1) f z
                 where zl = f u v

anneSP f z = find (0,z) f z
anneS = anneSP f1



bsearch ::(Integral a)=> (a->a)->(a,a)->a->a
bsearch g (l,h) z | (l + 1) == h = l
                  | g m <= z  = bsearch g (m,h) z
                  | otherwise = bsearch g (l,m) z
                     where m = div (l+h) 2

theoSP3 ::(Integral a)=> (a->a->a)->a->[(a,a)]
theoSP3 f z = find (0,m) f z 
                where m = bsearch (f 0) (-1,z+1) z


theoS3 = theoSP3 f1



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

maryS3 =marySP3 f1