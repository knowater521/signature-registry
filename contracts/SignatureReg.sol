//! A decentralised registry of 4-bytes signatures => method mappings
//!
//! Copyright 2016 Jaco Greef, Parity Technologies Ltd.
//!
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//!
//!     http://www.apache.org/licenses/LICENSE-2.0
//!
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.

pragma solidity ^0.4.1;

import "./Owned.sol";


contract SignatureReg is Owned {
	// mapping of signatures to entries
	mapping (bytes4 => string) public entries;

	// the total count of registered signatures
	uint public totalSignatures = 0;

	// allow only new calls to go in
	modifier when_unregistered(bytes4 _signature) {
		if (bytes(entries[_signature]).length != 0) return;
		_;
	}

	// dispatched when a new signature is registered
	event Registered(address indexed creator, bytes4 indexed signature, string method);

	// constructor with self-registration
	function SignatureReg() {
		register('register(string)');
	}

	// registers a method mapping
	function register(string _method) returns (bool) {
		return _register(bytes4(sha3(_method)), _method);
	}

	// internal register function, signature => method
	function _register(bytes4 _signature, string _method) internal when_unregistered(_signature) returns (bool) {
		entries[_signature] = _method;
		totalSignatures = totalSignatures + 1;
		Registered(msg.sender, _signature, _method);
		return true;
	}

	// in the case of any extra funds
	function drain() only_owner {
		if (!msg.sender.send(this.balance)) {
			throw;
		}
	}
}