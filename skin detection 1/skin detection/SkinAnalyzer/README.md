# AI Skin Analyzer

An AI-powered skin analysis application that uses MediaPipe Face Mesh to capture facial images and analyze skin conditions.

## Features

- Real-time facial landmark detection using MediaPipe
- Smart image capture with lighting and position detection
- Multi-view analysis (front, left, right)
- Skin issue scoring and classification
- Product recommendations based on analysis
- PDF report generation
- Modern, responsive UI with Tailwind CSS

## Project Structure

```
src/
├── components/           # React components
│   ├── SkinAnalyzer.js   # Main component
│   ├── WebcamView.js     # Webcam display component
│   ├── ResultsPanel.js   # Results display component
│   ├── IssueScores.js    # Issue scores grid
│   └── Recommendations.js # Recommendations display
├── hooks/                # Custom React hooks
│   ├── useFaceMesh.js    # Face mesh initialization
│   └── useSkinAnalysis.js # Analysis state management
├── services/             # API services
│   └── analysisService.js # Backend API calls
├── utils/                # Utility functions
│   ├── faceMeshUtils.js  # Face mesh utilities
│   └── pdfGenerator.js   # PDF report generation
├── constants/            # Constants and configurations
│   └── skinIssues.js     # Skin issue definitions
├── App.js               # Main app component
├── index.js             # App entry point
└── index.css            # Global styles
```

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm start
```

3. Make sure your backend API is running on `http://127.0.0.1:5000`

## Dependencies

- React 18.2.0
- MediaPipe Face Mesh
- jsPDF for report generation
- Tailwind CSS for styling

## API Endpoints

The application expects a backend API with the following endpoint:

- `POST /analyze` - Analyzes captured images and returns skin analysis results

## Usage

1. Allow camera access when prompted
2. Click "Start Scan" to begin the analysis
3. Follow the on-screen instructions to capture front, left, and right views
4. View the analysis results and recommendations
5. Download a PDF report if needed

## Development

The code is organized into logical modules:

- **Components**: Reusable UI components
- **Hooks**: Custom React hooks for state management
- **Services**: API communication layer
- **Utils**: Helper functions and utilities
- **Constants**: Application constants and configurations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License 