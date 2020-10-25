# NFT based Auth Token💳

***
## 【Introduction of NFT based Auth Token💳】
- This is the smart contract that NFT is used for the ACL management.

<br>

- NFT Auth Token works as a ACL Token.
  - User who has a NFT Auth Token, they can access contents which is permitted. 
    (Admin has tokenID=1, User has tokenID that is greater than 2)
  - Login by being checked whether user has a NFT Auth Token or not.
  - IPFS hash is created by uploading an image of user profile.

<br>

- 1 NFT Auth Token, 1 Pool for staking and earning interest (in the future) 




&nbsp;

***

## 【Setup】
1. Npm install
```
$ npm install
```

<br>


2. Migrate
```
$ npm run migrate:kovan
```

&nbsp;

## 【Test】
- Testing for all contract (※ `Kovan test network` )
```
$ npm run test:kovan
```


<br>

***

## 【References】
- [Untitled: NFT Hackathon]:
  - Website
    
  
  - Information
    https://metaforce.substack.com/p/introducing-untitled-nft-hackathon
    https://twitter.com/NFT_hack 
    https://medium.com/ethplanet/ethplanet-hackathon-building-the-next-digital-world-2d0246027d78
