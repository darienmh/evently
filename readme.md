# Introduction
"Evently" is a decentralized application on the Stacks blockchain designed to empower event organizers to manage and sell event tickets directly, without the need for external ticketing agents. This contract facilitates the creation, updating, and purchasing of event tickets, while also providing mechanisms to query ticket and event details efficiently.

# Features
- **Create Events**: Organizers can create events with defined ticket prices, limits, and expiry dates.
- **Update Events**: Event details can be updated by the organizer or the contract owner.
- **Purchase Tickets**: Attendees can purchase tickets if available, with checks to ensure sales do not exceed predefined limits.
- **Query Events and Tickets**: Users can retrieve details about specific events or tickets and list all tickets owned.

# Contract Deployment
This contract is deployed on the Stacks testnet. The smart contract address and relevant details are as follows:

- **Contract Address**: ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5
- **Contract Name**: evently1

# Setup Instructions
Before interacting with the contract, ensure you have a Stacks wallet setup and you are connected to the Stacks testnet. You can use the Hiro Wallet for web interactions.

# API Reference
## Public Functions
### add-event
**Description**: Creates a new event. Fails if an event with the same ID already exists.

**Parameters**:

- `event-id (string-ascii 40)`: Unique identifier for the event.
- `price-per-ticket (uint)`: Price per ticket in microstacks.
- `ticket-limit (uint)`: Maximum number of tickets available for this event.
- `expiry (uint)`: Expiry date of the event as UNIX timestamp.

**Returns**: Confirmation message indicating success or failure.

### update-event
**Description**: Updates the details of an existing event. This function can only be called by the event's current owner or the contract owner. It ensures that the updated ticket limit does not fall below the number of tickets already sold.

**Parameters**:

- `event-id (string-ascii 40)`: The unique identifier of the event to update.
- `owner (principal)`: The new owner of the event, typically the same unless ownership is being transferred.
- `price-per-ticket (uint)`: The updated price per ticket.
- `ticket-limit (uint)`: The updated limit on the number of tickets that can be sold. This cannot be less than the number of tickets already sold.
- `expiry (uint)`: The updated expiry time for the event.

**Returns**: Success confirmation if the event is updated correctly, or an error if not authorized, if the event does not exist, or if the new ticket limit is invalid.

### buy-ticket
**Description**: Allows a user to purchase a ticket for an event, given that tickets are still available and the event has not expired. This function updates the total number of tickets sold and adds the new ticket under the buyer's ownership.

**Parameters**:

- `event-id (string-ascii 40)`: The ID of the event for which a ticket is being purchased.
- `ticket-id (string-ascii 40)`: The unique identifier for the new ticket.

**Returns**: A confirmation of the ticket purchase. Returns an error if the event ID or ticket ID is empty, the event does not exist, the ticket limit has been reached, the event has expired, or the ticket ID is already registered.

## Read-Only Functions
### get-event
**Description**: Retrieves details for a specific event by ID.

**Parameters**:

- `event-id (string-ascii 40)`: The event identifier.

**Returns**: Event details including owner, ticket price, limit, sold count, and expiry.

### get-ticket
**Description**: Fetches the details associated with a specific ticket, including the event it is for and who owns it. This is useful for validation and verification purposes.

**Parameters**:

- `ticket-id (string-ascii 40)`: The unique identifier for the ticket.
**Returns**: A tuple with the ticket's details (event-id, owner) if the ticket exists, or none if the ticket cannot be found.

### get-tickets-by-owner
**Description**: Lists all tickets owned by a specific principal address. This function compiles tickets from multiple events, providing a comprehensive overview of a user's ticket holdings.

**Parameters**:

- `owner (principal)`: The Stacks address of the user whose tickets are being queried.
**Returns**: A list of tickets (each as a tuple of event-id and ticket-id) owned by the specified user if any exist, or an empty list if the user owns no tickets.

# Common Errors
- `ERR_UNKNOWN_EVENT (404)`: No event found with the specified ID.
- `ERR_UNAUTHORISED (403)`: Caller is not authorized to perform the requested operation.
- `ERR_EVENT_EXPIRED (410)`: Attempt to operate on an expired event.
- `ERR_ALREADY_REGISTER (409)`: Event with the given ID already exists.

# Contributors
This project is brought to you by the following developers, who have contributed their time and skills to bring "Evently" to life:

- @darienmh
- @Andresdev-gek
