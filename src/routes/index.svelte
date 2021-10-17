<script>
	// @ts-nocheck

	import { onMount } from 'svelte';
	import { ethers } from 'ethers';
	import myEpicNft from '$web3/artifacts/contracts/MyEpicNFT.sol/MyEpicNFT.json';

	// Constants
	const TWITTER_HANDLE = 'rodg_co';
	const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
	const OPENSEA_LINK = '';
	const TOTAL_MINT_COUNT = 50;
	const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS;

	let account;
	let provider;
	let signer;
	let connectedContract;

	onMount(async () => {
		const { ethereum } = window;

		if (!ethereum) {
			console.log('Make sure you have Metamask!');
		} else {
			console.log('We have the ethereum object', ethereum);
		}

		provider = new ethers.providers.Web3Provider(ethereum);
		signer = provider.getSigner();
		connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myEpicNft.abi, signer);

		connectedContract.on('NewEpicNFTMinted', (from, tokenId) => {
			console.log(from, tokenId.toNumber());
			alert(
				`Hey there! We minted your NFT. It be blank right now. It can take a max 0 min to show up on OpenSea. Here's the link: https://testnets.opensea.io/assets/${CONTRACT_ADDRESS}/${tokenId.toNumber()}`
			);
		});

		const accounts = await ethereum.request({ method: 'eth_accounts' });

		if (accounts.length !== 0) {
			account = accounts[0];
			console.log('Found an authorized acount:', account);
		} else {
			console.log('No authorized account found');
		}
	});

	async function connectWallet() {
		try {
			const { ethereum } = window;

			if (!ethereum) {
				alert('Get Metamask!');
				return;
			}

			const accounts = await ethereum.request({ method: 'eth_requestAccounts' });

			console.log('Connected', accounts[0]);
			account = accounts[0];
		} catch (error) {
			console.log(error);
		}
	}

	async function mintNFT() {
		try {
			const { ethereum } = window;

			if (!ethereum) {
				console.log("Ethereum object doesn't exist! Get Metamask!");
				return;
			}

			console.log('Poping up wallet to pay gas...');
			let nftTxn = await connectedContract.makeAnEpicNFT();

			console.log('Mining... please wait.');
			await nftTxn.wait();

			console.log(`Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);
		} catch (error) {
			console.log(error);
		}
	}
</script>

<div class="App">
	<div class="container">
		<div class="header-container">
			<p class="header gradient-text">My NFT Collection</p>
			<p class="sub-text">Each unique. Each beautiful. Discover your NFT today.</p>
			{#if !account}
				<button class="cta-button connect-wallet-button" on:click={connectWallet}>
					Connect to Wallet
				</button>
			{:else}
				<button class="cta-button mint-button" on:click={mintNFT}> Mint NFT </button>
			{/if}
		</div>
		<div class="footer-container">
			<img alt="Twitter" src="/assets/twitter-logo.svg" />
			<a class="footer-text" href={TWITTER_LINK} target="_blank" rel="noreferrer"
				>{`built on @${TWITTER_HANDLE}`}</a
			>
		</div>
	</div>
</div>
