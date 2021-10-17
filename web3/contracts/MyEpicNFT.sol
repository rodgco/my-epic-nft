pragma solidity 0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	// This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
	// So, we make a baseSvg variable here that all our NFTs can use.
	string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px;  }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

	// I create three arrays, each with their own theme of random words.
	// Pick some random funny words, names of anime characters, foods you like, whatever! 
	string[] firstWords = ["Amazing", "Incredible", "Pretty", "Gorgeous", "Bestial"];
	string[] secondWords = ["Token", "Ball", "Chair", "Community", "Course", "Track"];
	string[] thirdWords = ["Hat", "Color", "Flavour", "Texture", "Brightness"];

	event NewEpicNFTMinted(address sender, uint256 tokenId);

	constructor() ERC721 ("SquareNFT", "SQUARE") {
		console.log("This is my NFT contract. Woah!");
	}

	function pickRandom(string memory seed, uint256 tokenId) public view returns (uint256) {
		return uint256(keccak256(abi.encodePacked(string(abi.encodePacked(seed, Strings.toString(tokenId), msg.sender)))));
	}

	function makeAnEpicNFT() public {
		uint256 newItemId = _tokenIds.current();

		// We go and randomly grab one word from each of the three arrays.
		string memory first = firstWords[pickRandom("FIRST_WORD", newItemId) % firstWords.length];
		string memory second = secondWords[pickRandom("SECOND_WORD", newItemId) % secondWords.length];
		string memory third = thirdWords[pickRandom("THIRD_WORD", newItemId) % thirdWords.length]; 
		string memory combinedWord = string(abi.encodePacked(first, second, third));

		string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

		// Get all the JSON metadata in place and base64 encode it.
		string memory json = string(
			abi.encodePacked(
				'{"name": "', combinedWord, '",',
				'"description": "A highly acclaimed collection of squares.",',
				'"image": "data:image/svg+xml;base64,', Base64.encode(bytes(finalSvg)),
				'"}'
			)
		);

		console.log("JSON", json);

		string memory jsonBase64 = Base64.encode(bytes(json));

		// Just like before, we prepend data:application/json;base64, to our data.
		string memory finalTokenUri = string(
			abi.encodePacked("data:application/json;base64,", jsonBase64)

		);

		console.log("\n--------------------");
		console.log(finalTokenUri);
		console.log("--------------------\n");

		_safeMint(msg.sender, newItemId);

		// Update your URI!!!
		_setTokenURI(newItemId, finalTokenUri);

		_tokenIds.increment();
		console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

		emit NewEpicNFTMinted(msg.sender, newItemId);
	}
}
