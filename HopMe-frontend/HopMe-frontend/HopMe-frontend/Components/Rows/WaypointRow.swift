import SwiftUI

struct WaypointRow: View {
    let waypoint: Waypoint
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Line indicator
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 20)
                }
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 20)
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(waypoint.location)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let estimatedTime = waypoint.estimatedTime {
                    Text(estimatedTime.formatted(time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
    }
}
