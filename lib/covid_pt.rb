require "sort_alphabetical"
require "covid_pt/printer"
require "covid_pt/report"
require "covid_pt/utils"
require "covid_pt/version"

module CovidPT
  class Error < StandardError; end

  extend self

  def at(date)
    CovidPT::Report.new(date).generate.merge({type: "report"})
  end

  def compare(from, to)
    report_1 = CovidPT::Report.new(from).generate
    report_2 = CovidPT::Report.new(to).generate

    {
      overall: Utils.diff(report_2[:overall], report_1[:overall]),
      regional: Utils.diff(report_2[:regional], report_1[:regional]),
      dates: {
        from: report_1[:date],
        to: report_2[:date]
      },
      type: "comparison"
    }
  end

  def range(from, to)
    from_date = Date.parse(from)
    to_date = Date.parse(to)

    dates = (from_date..to_date).to_a
    reports = (from_date..to_date).map { |d| CovidPT::Report.new(d.to_s).generate }

    i = 0
    acc = {overall: {}, regional: {}, dates: dates, type: "range"}

    while i < reports.length - 1 do
      report_1 = reports[i]
      report_2 = reports[i + 1]

      acc[:overall] = Utils.cumulative_diff(
        report_1[:overall],
        report_2[:overall],
        acc[:overall]
      )

      acc[:regional] = Utils.cumulative_diff(
        report_1[:regional],
        report_2[:regional],
        acc[:regional]
      )

      i += 1
    end

    acc
  end
end
