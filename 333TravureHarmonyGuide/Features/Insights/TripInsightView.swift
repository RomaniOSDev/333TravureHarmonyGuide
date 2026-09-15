import SwiftUI

struct BriefsLibraryView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                RidgeBanner(imageName: "bannerMarket")
                LiftPassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ridge briefs")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Color("AppInk"))
                        Text("Original field notes for how a ski morning actually starts. These are not destination pages and not a travel journal — each brief changes the kit and the dawn script.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Color("AppInk").opacity(0.8))
                    }
                }

                ForEach(RidgeCatalog.all) { brief in
                    NavigationLink {
                        BriefDetailView(brief: brief)
                    } label: {
                        LiftPassCard {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: brief.symbol)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(Color("AppAccent"))
                                    .frame(width: 36, height: 36)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(brief.name)
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundColor(Color("AppInk"))
                                    Text(brief.range)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(Color("AppInk").opacity(0.75))
                                    Text(brief.snowRead)
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(Color("AppInk").opacity(0.7))
                                        .lineLimit(3)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("AppAccent"))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("brief_\(brief.id)")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .clearScrollBackground()
    }
}
