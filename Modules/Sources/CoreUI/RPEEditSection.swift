//
//  RPEEditSection.swift
//  Modules
//
//  Created by Inal Gotov on 2025-11-13.
//

import Data
import SwiftUI

struct RPEEditSection: View {
    @Binding var externalRateOfPerceivedExertion: Int

    @Binding private var rateOfPerceivedExertion: Double
    @State private var isRatingExertion: Bool

    @State private var isShowingMoreDetails: Bool = true

    private var labelText: String {
        if isRatingExertion {
            "Rate of Perceived Exertion: \(Int(rateOfPerceivedExertion))"
        } else {
            "Rate of Perceived Exertion"
        }
    }

    init(_ rateOfPerceivedExertion: Binding<Int>) {
        _externalRateOfPerceivedExertion = rateOfPerceivedExertion
        _rateOfPerceivedExertion = Binding(get: {
            max(Double(rateOfPerceivedExertion.wrappedValue), 0)
        }, set: { newValue in
            rateOfPerceivedExertion.wrappedValue = Int(newValue.rounded())
        })
        _isRatingExertion = State(initialValue: rateOfPerceivedExertion.wrappedValue >= 0)
    }

    var body: some View {
        Section {
            Toggle(labelText, isOn: $isRatingExertion.animation())

            if isRatingExertion {
                if #available(iOS 26, *) {
                    tickedSlider
                } else {
                    simpleSlider
                }

                infoRow
            }
        }
        .animation(.default, value: isShowingMoreDetails)
        .onChange(of: isRatingExertion) {
            if isRatingExertion {
                externalRateOfPerceivedExertion = Int(rateOfPerceivedExertion.rounded())
            } else {
                externalRateOfPerceivedExertion = -1
            }
        }
    }

    @available(iOS 26, *)
    private var tickedSlider: some View {
        Slider(
            value: $rateOfPerceivedExertion,
            in: 0...10
        ) {
            Text("Rate of Perceived Exertion")
        } currentValueLabel: {
            Text("\(Int(rateOfPerceivedExertion))")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("10")
        } ticks: {
            let values = (0...10).map { Double($0) }
            SliderTickContentForEach(values, id: \.self) { value in
                SliderTick(value)
            }
        } onEditingChanged: { _ in
        }
        .labelsHidden()
    }

    private var simpleSlider: some View {
        Slider(
            value: $rateOfPerceivedExertion,
            in: 0...10
        ) {
            Text("Rate of Perceived Exertion")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("10")
        } onEditingChanged: { _ in
        }
        .labelsHidden()
    }

    private var infoRow: some View {
        VStack(alignment: .leading) {
            Text("Rate of perceived exertion is a rating of how hard you think you pushed yourself during a set.")
                .fixedSize(horizontal: false, vertical: true)

            if isShowingMoreDetails {
                Group {
                    Text("It is a subjective metric that can be used to judge your overall load and whether you should pushed harder or go lighter then next time you perform this exercise. Below is a typical breakdown of the values used in the scale.")
                        .padding(.vertical, 4)

                    Text("•") + Text(" 0")
                        .foregroundStyle(Segment.Set.color(forRpe: 0)) +
                    Text(": No effort/at rest")

                    Text("•") + Text(" 1")
                        .foregroundStyle(Segment.Set.color(forRpe: 1)) +
                    Text(": Very light effort")

                    Text("•") + Text(" 2-3")
                        .foregroundStyle(Segment.Set.color(forRpe: 3)) +
                    Text(": Light effort")

                    Text("•") + Text(" 4-5")
                        .foregroundStyle(Segment.Set.color(forRpe: 5)) +
                    Text(": Moderate exertion. Heavy breathing and elevated heart rate.")

                    Text("•") + Text(" 6-7")
                        .foregroundStyle(Segment.Set.color(forRpe: 7)) +
                    Text(": High exertion. 1-2 more sets left after this one. Difficulty holding a conversation.")

                    Text("•") + Text(" 8-9")
                        .foregroundStyle(Segment.Set.color(forRpe: 9)) +
                    Text(": Very hard. 1 to 2 reps left after this set. Unable to carry a conversation.")

                    Text("•") + Text(" 10")
                        .foregroundStyle(Segment.Set.color(forRpe: 10)) +
                    Text(": Maximum exertion. No more reps left after this set.")
                }
                .transition(.move(edge: .top))
            }

            Button(isShowingMoreDetails ? "Show less" : "Show more") {
                withAnimation {
                    isShowingMoreDetails.toggle()
                }
            }
            .buttonStyle(.borderless)
            .foregroundStyle(Color.accentColor)
            .padding(.vertical, 4)
        }
        .multilineTextAlignment(.leading)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}

#if DEBUG

#Preview {
    @Previewable @State var rate: Int = 0

    Form {
        RPEEditSection($rate)
    }
    .overlay(alignment: .bottom) {
        Text("\(rate)")
    }
}

#endif
