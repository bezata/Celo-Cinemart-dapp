// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MovieStore {
    // Changed the string variables in the Movie struct to bytes32 variables. This reduces gas costs and makes it less likely that you will run out of gas when adding a new movie.


    struct Movie {
        address productionCo;
        bytes32 title;
        bytes32 director;
        bytes32 image;
        bytes32 description;
        uint256 price;
        uint copiesAvailable;
    }
    
    mapping (uint256 => Movie) public movies;
    uint256 public movieCount;
    
    address public owner;
    mapping (address => bool) public authorized;

    bool public paused; // Added variable to keep track of whether purchases are currently paused
    
    event MovieAdded(uint256 movieId, bytes32 title, bytes32 director);
    event MoviePurchased(uint256 movieId, bytes32 title, bytes32 director);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyAuthorized(){
        require(authorized[msg.sender], "Only authorized users can call this function.");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        authorized[owner] = true;
        paused = false; // Set the paused flag to false by default
    }
    
    function addMovie(bytes32 _title, bytes32 _image, bytes32 _description, bytes32 _director, uint256 _price, uint _copiesAvailable) public onlyAuthorized() {
        movieCount++;
        movies[movieCount] = Movie(msg.sender, _title, _director, _image, _description, _price, _copiesAvailable);
        emit MovieAdded(movieCount, _title, _director);
    }
    // Added an updateMovie() function to allow movie information to be updated after it has been added.
    function updateMovie(uint256 _movieId, bytes32 _title, bytes32 _image, bytes32 _description, bytes32 _director, uint256 _price, uint _copiesAvailable) public onlyAuthorized() {
        require(_movieId <= movieCount, "Movie does not exist.");
        movies[_movieId] = Movie(msg.sender, _title, _director, _image, _description, _price, _copiesAvailable);
    }
    
    function authorize(address _address) public onlyOwner {
        authorized[_address] = true;
    }
    
    function revoke(address _address) public onlyOwner {
        authorized[_address] = false;
    }
    // function to retrieve the information for a movie
    function buyMovie(uint256 _movieId) public payable {
        require(!paused, "Purchases are currently paused."); // Added check to make sure purchases are not currently paused
        require(authorized[msg.sender], "Only authorized users can purchase movies.");
        require(movies[_movieId].price == msg.value, "Incorrect amount of Ether sent.");
        // // Make sure the movie ID is valid
        require(movies[_movieId].copiesAvailable > 0, "Movie has already been purchased.");
        // This check ensures that the movie ID passed to buyMovie() is valid and that the movie is still available for purchase. If the movie has already been purchased or the movie ID is invalid, the function will return an error message.
        movies[_movieId].copiesAvailable--;
        getMovie(_movieId);
        emit MoviePurchased(_movieId, movies[_movieId].title, movies[_movieId].director);
    }
    // function to retrieve the total number of movies that have been added to the contract
    function getMovie(uint256 _movieId) public view returns (address, bytes32, bytes32, bytes32, bytes32, uint256, uint) {
        require(_movieId <= movieCount, "Movie does not exist.");
        return (movies[_movieId].productionCo ,movies[_movieId].title, movies[_movieId].director, movies[_movieId].image, movies[_movieId].description, movies[_movieId].price, movies[_movieId].copiesAvailable);
    }

    function getMovies() public view returns(uint) {
        return(movieCount);
    }
    // paused flag to keep track of whether purchases are currently paused. This allows the contract owner to temporarily disable purchases if needed.
    function pause() public onlyOwner {
        paused = true; // Set the paused flag to true
    }
    
    function unpause() public onlyOwner {
        paused = false; // Set the paused flag to false
    }
}