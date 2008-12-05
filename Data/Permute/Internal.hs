{-# LANGUAGE MultiParamTypeClasses, TypeFamilies, FlexibleContexts #-}
-----------------------------------------------------------------------------
-- |
-- Module     : Data.Permute.Internal
-- Copyright  : Copyright (c) , Patrick Perry <patperry@stanford.edu>
-- License    : BSD3
-- Maintainer : Patrick Perry <patperry@stanford.edu>
-- Stability  : experimental
--

module Data.Permute.Internal 
    where
    
import Control.Monad
import Control.Monad.ST

import Data.Array.IO
import Data.Array.ST
import Data.Array.Unboxed



--------------------------------- Permute ---------------------------------

-- | The immutable permutation data type.
data Permute = Permute {
      size  :: !Int
    , array :: !(UArray Int Int)
    }

-- | Construct a permutation from a list of elements.  
-- @listPermute n is@ creates a permuation of size @n@ with
-- the @i@th element equal to @is !! i@.  For the permutation to be valid,
-- the list @is@ must have length @n@ and contain the indices @0..(n-1)@ 
-- exactly once each.
listPermute :: Int -> [Int] -> Permute
listPermute = undefined

-- | Construct a permutation from a list of swaps.
-- @swapsPermute n ss@ creats a permuation of size @n@ from the sequence
-- of swaps.  For example, if @ss@ is @[(i0,j0), (i1,j1), ..., (ik,jk)]@, the
-- sequence of swaps is
-- @i0 \<-> j0@, then 
-- @i1 \<-> j1@, and so on until
-- @ik \<-> jk@.
swapsPermute :: Int -> [(Int,Int)] -> Permute
swapsPermute = undefined

-- | Construct an identity permutation of th given size.
identity :: Int -> Permute
identity = undefined

-- | @apply p i@ gets the value of the @i@th element of the permutation
-- @p@.  The index @i@ must be in the range @0..(n-1)@, where @n@ is the
-- size of the permutation.
apply :: Permute -> Int -> Int
apply = undefined
{-# INLINE apply #-}

-- | Get a list of the permutation elements.
elems :: Permute -> [Int]
elems = undefined

-- | Get the inverse of a permutation
inverse :: Permute -> Permute
inverse = undefined

-- | Return the next permutation in lexicographic order, or @Nothing@ if
-- there are no further permutations.  Starting with the identity permutation
-- and repeatedly calling this function will iterate through all permutations
-- of a given order.
next :: Permute -> Maybe Permute
next = undefined

-- | Return the previous permutation in lexicographic order, or @Nothing@
-- if there is no such permutation.
prev :: Permute -> Maybe Permute
prev = undefined

-- | Get a list of swaps equivalent to the permutation.  The returned list will
-- have length equal to the size of the permutation.  A result of
-- @[ i0, i1, ..., in1 ]@ means swap @0 <-> i0@, then @1 <-> i1@, and so on
-- until @(n-1) <-> in1@.
swaps :: Permute -> [Int]
swaps = undefined

-- | Get a list of swaps equivalent to the inverse of permutation.  The 
-- returned list will have length equal to the size of the permutation.
invSwaps :: Permute -> [Int]
invSwaps = undefined


--------------------------------- MPermute --------------------------------

-- | Class for the associated array type of the underlying storage for a 
-- permutation.  Internally, a permutation of size @n@ is stored as an
-- @0@-based array of @n@ 'Int's.  The permutation represents a reordering of
-- the integers @0, ..., (n-1)@.  The @i@th element of the array stores
-- the value @p_i@. 
class HasPermuteArray p where
    -- | The underlying array type.
    type PermuteArray p :: * -> * -> *

-- | The 'Int' array type associated with a permutation type @p@.
type PermuteData p = PermuteArray p Int Int

-- | Class for representing a mutable permutation.  The type is parameterized
-- over the type of the monad, @m@, in which the mutable permutation will be
-- manipulated.
class (HasPermuteArray p, MArray (PermuteArray p) Int m) => MPermute p m where
    
    -- | Allocate a new permutation but do not initialize it.
    newPermute_ :: Int -> m p
    
    -- | Create a new permutation initialized to be the identity.
    newPermute  :: Int -> m p
    newPermute n = do
        p <- newPermute_ n
        setIdentity p
        return p

    -- | Get the size of the permutation.
    getSize :: p -> m Int
    
    -- | Get the underlying array that stores the permutation
    getData :: p -> m (PermuteData p)
        
-- | Construct a permutation from a list of elements.  
-- @newListPermute n is@ creates a permuation of size @n@ with
-- the @i@th element equal to @is !! i@.  For the permutation to be valid,
-- the list @is@ must have length @n@ and contain the indices @0..(n-1)@ 
-- exactly once each.
newListPermute :: (MPermute p m) => Int -> [Int] -> m p
newListPermute = undefined

-- | Construct a permutation from a list of swaps.
-- @newSwapsPermute n ss@ creats a permuation of size @n@ from the sequence
-- of swaps.  For example, if @ss@ is @[(i0,j0), (i1,j1), ..., (ik,jk)]@, the
-- sequence of swaps is
-- @i0 \<-> j0@, then 
-- @i1 \<-> j1@, and so on until
-- @ik \<-> jk@.
newSwapsPermute :: (MPermute p m) => Int -> [(Int,Int)] -> m p
newSwapsPermute = undefined

-- | Construct a new permutation by copying another.
newCopyPermute :: (MPermute p m, MPermute q m) => p -> m q
newCopyPermute = undefined

-- | @copyPermute dst src@ copies the elements of the permutation @src@
-- into the permtuation @dst@.  The two permutations must have the same
-- size.
copyPermute :: (MPermute q m, MPermute p m) => q -> p -> m ()
copyPermute = undefined

-- | Set a permutation to the identity.
setIdentity :: (MPermute p m) => p -> m ()
setIdentity = undefined

-- | @getPermute p i@ gets the value of the @i@th element of the permutation
-- @p@.  The index @i@ must be in the range @0..(n-1)@, where @n@ is the
-- size of the permutation.
getPermute :: (MPermute p m) => p -> Int -> m Int
getPermute = undefined
{-# INLINE getPermute #-}

-- | @swapPermute p i j@ exchanges the @i@th and @j@th elements of the 
-- permutation @p@.
swapPermute :: (MPermute p m) => p -> Int -> Int -> m ()
swapPermute = undefined
{-# INLINE swapPermute #-}

-- | Get a lazy list of the permutation elements.  The laziness makes this
-- function slightly dangerous if you are modifying the permutation.  See also
-- 'getElems\''.
getElems :: (MPermute p m) => p -> m [Int]
getElems = undefined

-- | Get a strict list of the permutation elements.
getElems' :: (MPermute p m) => p -> m [Int]
getElems' = undefined

-- | Returns whether or not the permutation is valid.  For it to be valid,
-- the numbers @0,...,(n-1)@ must all appear exactly once in the stored
-- values @p[0],...,p[n-1]@.
isValid :: (MPermute p m) => p -> m Bool
isValid = undefined

-- | Compute the inverse of a permutation.  @setInverse inv p@ computes the
-- inverse of @p@ and stores it in @inv@.
setInverse :: (MPermute pi m, MPermute p m) => pi -> p -> m ()
setInverse = undefined

-- | Advance a permutation to the next permutation in lexicogrphic order and
-- return @True@.  If no further permutaitons are available, return @False@ and
-- leave the permutation unmodified.  Starting with the idendity permutation 
-- and repeatedly calling @setNext@ will iterate through all permutations of a 
-- given size.
setNext :: (MPermute p m) => p -> m Bool
setNext = undefined

-- | Step backwards to the previous permutation in lexicographic order and
-- return @True@.  If there is no previous permutation, return @False@ and
-- leave the permutation unmodified.
setPrev :: (MPermute p m) => p -> m Bool
setPrev = undefined

-- | Get a list of swaps equivalent to the permutation.  The returned list will
-- have length equal to the size of the permutation.  A result of
-- @[ i0, i1, ..., in1 ]@ means swap @0 <-> i0@, then @1 <-> i1@, and so on
-- until @(n-1) <-> in1@.
getSwaps :: (MPermute p m) => p -> m [Int]
getSwaps = undefined

-- | Get a list of swaps equivalent to the inverse of permutation.  The 
-- returned list will have length equal to the size of the permutation.
getInvSwaps :: (MPermute p m) => p -> m [Int]
getInvSwaps = undefined

-- | Convert a mutable permutation to an immutable one
freeze :: (MPermute p m) => p -> m Permute
freeze = undefined

unsafeFreeze :: (MPermute p m) => p -> Permute
unsafeFreeze = undefined

-- | Convert an immutable permutation to a mutable one
thaw :: (MPermute p m) => Permute -> m p
thaw = undefined

unsafeThaw :: (MPermute p m) => Permute -> p
unsafeThaw = undefined


--------------------------------- Instances ---------------------------------

-- | A mutable permutation that can be manipulated in the 'ST' monad. The
-- type argument @s@ is the state variable argument for the 'ST' type.
data STPermute s = STPermute !Int !(STUArray s Int Int)

instance HasPermuteArray (STPermute s) where
    type PermuteArray (STPermute s) = STUArray s
    
instance MPermute (STPermute s) (ST s) where
    newPermute_ n = liftM (STPermute n) $ newArray_ (0,n-1)
    
    getSize (STPermute n _) = return n
    {-# INLINE getSize #-}
    
    getData (STPermute _ a) = return a
    {-# INLINE getData #-}


-- | A mutable permutation that can be manipulated in the 'IO' monad.
data IOPermute = IOPermute !Int !(IOUArray Int Int)

instance HasPermuteArray IOPermute where
    type PermuteArray IOPermute = IOUArray
    
instance MPermute IOPermute IO where
    newPermute_ n = liftM (IOPermute n) $ newArray_ (0,n-1)
    
    getSize (IOPermute n _) = return n
    {-# INLINE getSize #-}
    
    getData (IOPermute _ a) = return a
    {-# INLINE getData #-}
