# Enhanced Visualization UI Demo

## Overview

The enhanced visualization screen provides a modern, real-time analytics dashboard with improved left-right side utilization and live data fetching capabilities.

## Key Improvements

### 1. **Better Layout Utilization**
- **Left Side (60%)**: Candidate profile, skills analysis, and performance charts
- **Right Side (40%)**: Job market insights, match scores, skill trends, and quick actions
- **Responsive Design**: Adapts to different screen sizes (mobile, tablet, desktop)

### 2. **Real-time Data Fetching**
- Live analytics data from API endpoints
- Automatic refresh capabilities
- Fallback to mock data if API is unavailable
- Loading states and error handling

### 3. **Enhanced Features**
- **Real-time Stats**: Live application counts, match rates, response times
- **Skill Trends**: Dynamic skill analysis with trend charts
- **Job Market Insights**: Current market demand and salary data
- **Performance Charts**: Interactive charts showing candidate performance
- **Quick Actions**: Export reports, schedule interviews, send emails

## Files Created/Modified

### New Files:
1. **`lib/presentation/views/enhanced_visualize_view.dart`** - Enhanced visualization screen
2. **`lib/services/analytics_service.dart`** - Service for real-time data fetching
3. **`start_flask_api.ps1`** - PowerShell script to start Flask API
4. **`update_ngrok_url.py`** - Python script to update ngrok URLs

### Modified Files:
1. **`lib/presentation/views/visualize_view.dart`** - Added floating action button to switch to enhanced view

## API Endpoints Used

The enhanced view connects to these API endpoints:

```
GET /analytics/real-time          - Real-time analytics data
GET /analytics/skill-trends       - Skill trend analysis
GET /analytics/candidate-performance - Candidate performance data
GET /analytics/job-market         - Job market insights
GET /analytics/performance-trends - Performance trend charts
POST /analytics/export            - Export reports
GET /analytics/dashboard-summary  - Dashboard summary
```

## How to Use

### 1. **Start the Flask API**
```powershell
# Run the PowerShell script
.\start_flask_api.ps1

# Or manually:
cd Semantic_ranker
python ats_flask_api.py
```

### 2. **Start ngrok (if needed)**
```bash
ngrok http 5000
```

### 3. **Update ngrok URL (if needed)**
```bash
python update_ngrok_url.py https://your-new-ngrok-url.ngrok-free.app
```

### 4. **Run the Flutter App**
```bash
flutter run
```

### 5. **Access Enhanced View**
- Navigate to the visualization screen
- Click the "Enhanced View" floating action button
- The enhanced view will load with real-time data

## Features Breakdown

### Left Side (60% width):
- **Candidate Profile**: Detailed candidate information with contact details
- **Skills Analysis**: Interactive skill progress bars with trend data
- **Performance Chart**: Line chart showing performance trends over time

### Right Side (40% width):
- **Job Market Insights**: Current market demand, competition, salary data
- **Match Score Card**: Prominent display of candidate match percentage
- **Skill Trends Chart**: Bar chart showing skill popularity
- **Quick Actions**: Export, schedule, email, and profile actions

### Top Section:
- **Real-time Stats Cards**: Live data with trend indicators
- **Refresh Button**: Manual data refresh capability
- **Loading States**: Smooth loading animations

## Data Sources

### Real-time Data:
- Application counts and trends
- Match rates and success metrics
- Response times and processing stats
- Skill demand and popularity

### Mock Data (Fallback):
- Predefined analytics data
- Skill trend simulations
- Candidate performance metrics
- Job market insights

## Responsive Design

The enhanced view adapts to different screen sizes:

- **Mobile**: Single column layout, stacked components
- **Tablet**: Two-column layout with optimized spacing
- **Desktop**: Full left-right split with maximum utilization

## Error Handling

- **API Failures**: Graceful fallback to mock data
- **Loading States**: Smooth loading animations
- **Error Messages**: User-friendly error displays
- **Retry Mechanisms**: Easy retry options for failed requests

## Customization

The enhanced view is highly customizable:

- **Colors**: Easily change theme colors
- **Layout**: Adjust left-right split ratios
- **Charts**: Modify chart types and data sources
- **Actions**: Add or remove quick action buttons

## Performance

- **Lazy Loading**: Components load as needed
- **Caching**: Data is cached for better performance
- **Animations**: Smooth, performant animations
- **Memory Management**: Proper disposal of resources

## Future Enhancements

Potential improvements for future versions:

1. **Real-time WebSocket**: Live data updates without refresh
2. **Advanced Filtering**: More sophisticated data filtering options
3. **Export Options**: Multiple export formats (PDF, Excel, CSV)
4. **Custom Dashboards**: User-customizable dashboard layouts
5. **AI Insights**: AI-powered insights and recommendations
6. **Collaboration**: Multi-user collaboration features
7. **Mobile App**: Native mobile app version
8. **Offline Support**: Offline data access and sync

