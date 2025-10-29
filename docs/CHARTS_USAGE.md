# Charts Usage Guide - fl_chart

## Overview
This project uses `fl_chart ^0.69.0` for rendering beautiful, interactive charts in the Admin Dashboard.

## Installation
The package is already added to `pubspec.yaml`:
```yaml
dependencies:
  fl_chart: ^0.69.0
```

## Implementation Locations

### Admin Dashboard Page
**File:** `lib/features/admin/presentation/pages/admin_dashboard_page.dart`

#### 1. Bar Charts
Used for displaying **User Growth** and **Activity Trends**

**Features:**
- Interactive tooltips on tap/hover
- Gradient-filled bars (teal gradient)
- Grid lines for better readability
- Auto-scaling Y-axis
- Responsive to data range

**Implementation:**
```dart
Widget _buildSimpleBarChart(ChartData chartData) {
  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxValue > 0 ? maxValue * 1.2 : 10,
      barGroups: [...],
      // ... configuration
    ),
  );
}
```

**Chart Configuration:**
- **Height:** 200px
- **Bar Width:** 16px
- **Border Radius:** 6px (top corners)
- **Colors:** Teal gradient (#00BFA5 → #1DE9B6)
- **Background Bars:** Semi-transparent white (5% opacity)

#### 2. Pie Charts (Donut Style)
Used for displaying **CPU** and **Memory** usage

**Features:**
- Donut style with center hole
- Icon and percentage in center
- Color-coded metrics
- No section spacing for clean look

**Implementation:**
```dart
Widget _buildPieMetric(String label, double percentage, Color color, IconData icon) {
  return PieChart(
    PieChartData(
      sectionsSpace: 0,
      centerSpaceRadius: 35,
      sections: [
        PieChartSectionData(value: percentage, color: color, radius: 12),
        PieChartSectionData(value: 100 - percentage, color: Colors.white.withOpacity(0.1), radius: 12),
      ],
    ),
  );
}
```

**Chart Configuration:**
- **Size:** 100x100px
- **Center Radius:** 35px
- **Section Radius:** 12px
- **CPU Color:** Blue Accent (#448AFF)
- **Memory Color:** Orange Accent (#FF9800)

## Chart Data Models

### ChartData
```dart
class ChartData {
  final List<ChartDataPoint> data;
  final String period;
  final Map<String, dynamic>? summary;
}
```

### ChartDataPoint
```dart
class ChartDataPoint {
  final String label;    // X-axis label
  final int value;       // Y-axis value
  final DateTime? timestamp;
}
```

## Color Palette

### Primary Colors
- **Teal Gradient:** `#00BFA5` → `#1DE9B6`
- **Background Dark:** `#1A1F2E`
- **Background Darker:** `#0F1419`

### Metric Colors
- **CPU:** `Colors.blueAccent` (#448AFF)
- **Memory:** `Colors.orangeAccent` (#FF9800)
- **Database:** `Colors.purpleAccent` (#E040FB)
- **Query Stats:** `Colors.tealAccent` (#64FFDA)
- **Requests:** `Colors.greenAccent` (#69F0AE)

### UI Elements
- **Grid Lines:** `Colors.white.withOpacity(0.1)`
- **Borders:** `Colors.white.withOpacity(0.2)`
- **Tooltips:** `#1A1F2E` with teal border
- **Text Primary:** `Colors.white`
- **Text Secondary:** `Colors.white60`

## Customization Examples

### 1. Changing Bar Chart Colors
```dart
barRods: [
  BarChartRodData(
    toY: dataPoint.value.toDouble(),
    gradient: LinearGradient(
      colors: [Color(0xFFYOUR_COLOR), Color(0xFFYOUR_COLOR)],
    ),
  ),
],
```

### 2. Adjusting Chart Height
```dart
SizedBox(
  height: 250,  // Change this value
  child: _buildSimpleBarChart(chartData),
)
```

### 3. Modifying Tooltip Style
```dart
touchTooltipData: BarTouchTooltipData(
  getTooltipColor: (_) => YOUR_COLOR,
  tooltipBorder: BorderSide(color: YOUR_COLOR, width: 1),
  // ... other properties
)
```

### 4. Changing Pie Chart Size
```dart
SizedBox(
  width: 120,   // Change width
  height: 120,  // Change height
  child: PieChart(...),
)
```

## Best Practices

### Performance
1. **Limit Data Points:** Keep bar charts under 20 data points for smooth performance
2. **Avoid Excessive Animations:** Use simple fade-in animations only
3. **Cache Chart Data:** Store fetched data to avoid unnecessary rebuilds

### Design
1. **Consistent Colors:** Use the project's color palette
2. **Readable Labels:** Ensure text is at least 10px
3. **Appropriate Spacing:** Maintain 12-16px spacing between charts
4. **Dark Theme:** All charts should work well on dark backgrounds

### Data Handling
1. **Handle Empty Data:** Show "No data available" message
2. **Validate Data Range:** Ensure maxY is greater than 0
3. **Format Numbers:** Use `toStringAsFixed()` for decimals
4. **Check Null Values:** Handle null/undefined data gracefully

## Troubleshooting

### Issue: Chart Not Displaying
**Solution:** Wrap chart in `SizedBox` with explicit height
```dart
SizedBox(
  height: 200,
  child: BarChart(...),
)
```

### Issue: Overflow Errors
**Solution:** Reduce number of data points or increase chart width
```dart
// Limit data points
final limitedData = chartData.data.take(15).toList();
```

### Issue: Labels Overlapping
**Solution:** Rotate labels or reduce font size
```dart
getTitlesWidget: (value, meta) {
  return RotatedBox(
    quarterTurns: 1,
    child: Text(label, style: TextStyle(fontSize: 9)),
  );
}
```

### Issue: Poor Performance
**Solution:** Disable animations or reduce complexity
```dart
BarChartData(
  titlesData: FlTitlesData(
    // Simplify title rendering
  ),
  // Avoid complex gradients on many bars
)
```

## Resources

- **fl_chart Documentation:** https://pub.dev/packages/fl_chart
- **GitHub Repository:** https://github.com/imaNNeo/fl_chart
- **Examples:** https://github.com/imaNNeo/fl_chart/tree/main/example
- **API Reference:** https://pub.dev/documentation/fl_chart/latest/

## Future Enhancements

### Potential Chart Types
1. **Line Charts:** For continuous time-series data
2. **Area Charts:** For cumulative statistics
3. **Scatter Charts:** For correlation analysis
4. **Radar Charts:** For multi-dimensional comparisons
5. **Mixed Charts:** Combining multiple chart types

### Interaction Features
1. **Zoom & Pan:** Allow users to explore data
2. **Data Point Selection:** Highlight and show details
3. **Chart Export:** Save charts as images
4. **Animation Controls:** Play/pause/speed controls
5. **Legend Toggle:** Show/hide data series

## Testing

### Visual Testing Checklist
- [ ] Charts render correctly on different screen sizes
- [ ] Tooltips display properly
- [ ] Colors match design system
- [ ] Labels are readable
- [ ] Animations are smooth
- [ ] Dark theme compatibility
- [ ] Data updates refresh charts

### Data Testing
- [ ] Empty data shows appropriate message
- [ ] Single data point renders correctly
- [ ] Maximum data points (20+) performs well
- [ ] Extreme values (very high/low) scale properly
- [ ] Negative values handled (if applicable)

## Maintenance

### When to Update fl_chart
- Security vulnerabilities reported
- Major new features needed
- Performance improvements available
- Bug fixes for issues you encounter

### Breaking Changes
Before updating, check:
1. **Changelog:** https://pub.dev/packages/fl_chart/changelog
2. **Migration Guide:** Usually provided in releases
3. **API Changes:** Test all chart implementations
4. **Visual Regression:** Compare before/after screenshots

---

**Last Updated:** December 2024  
**Package Version:** fl_chart ^0.69.0  
**Flutter Version:** 3.9.2+
