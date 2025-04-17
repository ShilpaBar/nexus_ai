# NexusAI Chat

A Flutter application providing a chat interface for NexusAI model with data collection for fine-tuning.

## Features

- Chat with NexusAI in a familiar messaging interface
- Send text prompts and receive AI-generated responses
- Clean, intuitive chat bubble UI
- User data collection with consent for AI improvement
- Data analysis and visualization tools
- Export collected data for model fine-tuning

## Setup

1. Clone this repository
2. Create a `.env` file in the root of the project
3. Add your NexusAI API key to the `.env` file:
   ```
   NEXUSAI_API_KEY=your_api_key_here
   ```
4. Run `flutter pub get` to install dependencies
5. Run the app with `flutter run -d chrome` for web deployment

## Getting a NexusAI API Key

1. Visit [Google AI Studio](https://ai.google.dev/) and create an account
2. Create a new API key
3. Copy the key and add it to your `.env` file

## Usage

### Chat Interface

The app features a simple chat interface:

1. Type your message in the text field at the bottom of the screen
2. Press the send button or hit enter to send your message
3. NexusAI will respond with a chat bubble
4. Continue the conversation naturally as you would in any messaging app

### Data Collection

The app includes features for user data collection:

1. A consent dialog is shown on first launch
2. User messages are stored locally with timestamps
3. Data can be exported for analysis and model fine-tuning
4. Privacy settings can be adjusted at any time

### Data Analysis

The Data Analysis screen provides insights into collected user data:

1. Basic statistics about conversations
2. Word frequency analysis
3. Timeline of conversations
4. Export functionality for further analysis or model training

## Using Collected Data for Fine-Tuning

The exported data can be used to fine-tune the NexusAI model:

1. Export user data from the app
2. Format the data according to NexusAI's fine-tuning requirements
3. Use the fine-tuning API to improve the model
4. Implement the fine-tuned model in the app for improved responses

## Technologies Used

- Flutter
- NexusAI API
- flutter_dotenv for environment variables
- shared_preferences for local data storage

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
