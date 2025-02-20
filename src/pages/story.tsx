import { MainNav } from "@/components/navigation/main-nav";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Eye, Database, Lightbulb } from "lucide-react";
import { cn } from "@/lib/utils";
import { Footer } from "@/components/landing/footer";
import { SporaChat } from "@/components/spora-chat";

const timeline = [
  {
    year: "Late 2024",
    title: "Research & Development",
    description: (
      <div className="space-y-2">
        <p>
          Started as an R&D project in collaboration with{" "}
          <a 
            href="https://efmi.nl" 
            target="_blank" 
            rel="noopener noreferrer"
            className="text-teal-600 hover:text-teal-700 font-medium"
          >
            EFMI Business School
          </a>
          , a leading institute in food retail research.
        </p>
        <div className="flex items-center gap-2 mt-1">
          <a 
            href="https://www.linkedin.com/school/efminl/"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1.5 text-xs font-medium text-teal-600 hover:text-teal-700 bg-teal-50 hover:bg-teal-100 px-2 py-1 rounded-full transition-colors"
          >
            <svg className="h-3.5 w-3.5" viewBox="0 0 24 24" fill="currentColor">
              <path d="M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.32 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.79M6.88 8.56a1.68 1.68 0 0 0 1.68-1.68c0-.93-.75-1.69-1.68-1.69a1.69 1.69 0 0 0-1.69 1.69c0 .93.76 1.68 1.69 1.68m1.39 9.94v-8.37H5.5v8.37h2.77z"/>
            </svg>
            EFMI Business School
          </a>
        </div>
      </div>
    )
  },
  {
    year: "Early 2025",
    title: "Development & Testing",
    description: "Developing and optimizing forecast dashboards for 5 commodities, building the web application, and conducting extensive testing with industry partners."
  },
  {
    year: "Late 2025",
    title: "Platform Launch",
    description: "Hopefully being operational and ready to help our first customers make data-driven decisions in commodity procurement!"
  }
];

const values = [
  {
    icon: Eye,
    title: "Transparency",
    description: "We believe in complete transparency in our performance metrics and development process, ensuring you always know how our predictions are made."
  },
  {
    icon: Database,
    title: "Data Driven",
    description: "Our decisions and predictions are powered by machine learning models trained on extensive historical data, providing rational and unbiased insights."
  },
  {
    icon: Lightbulb,
    title: "Keep it Simple",
    description: "Complex market dynamics translated into clear, actionable insights. Sophisticated technology made accessible and effective."
  }
];

const team = [
  {
    name: "Dr. Sarah Chen",
    role: "Chief Data Scientist",
    image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200&h=200",
    description: "Ph.D. in Machine Learning with 8+ years experience in commodity market analysis and predictive modeling."
  },
  {
    name: "Mark van der Berg",
    role: "Head of Market Analysis",
    image: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=200&h=200",
    description: "15 years of experience in agricultural commodities trading and market analysis at leading European firms."
  },
  {
    name: "Emma Thompson",
    role: "Platform Architect",
    image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=200&h=200",
    description: "Seasoned software architect specializing in high-performance financial platforms and real-time data systems."
  },
  {
    name: "David Patel",
    role: "Customer Success Lead",
    image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200&h=200",
    description: "Expert in agricultural procurement with a passion for helping businesses optimize their commodity strategies."
  }
];

export function StoryPage() {
  return (
    <div className="min-h-screen flex flex-col bg-white">
      <MainNav />

      <main className="flex-1">
        {/* Journey Section */}
        <div className="relative pt-32 pb-12 md:pt-40 md:pb-24 bg-gray-50">
          <div className="absolute inset-0 -z-10">
            <div className="absolute inset-0 bg-gradient-to-br from-teal-50 via-white to-emerald-50" />
            <svg
              className="absolute w-full h-full opacity-[0.15]"
              xmlns="http://www.w3.org/2000/svg"
            >
              <defs>
                <pattern
                  id="timeline-grid"
                  width="32"
                  height="32"
                  patternUnits="userSpaceOnUse"
                >
                  <path d="M0 32V0h32" fill="none" stroke="currentColor" strokeOpacity="0.2" />
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="url(#timeline-grid)" />
            </svg>
          </div>

          <div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="max-w-3xl mx-auto text-center space-y-8">
              <h1 className="text-4xl md:text-5xl font-bold tracking-tight">
                Our Journey to{" "}
                <span className="bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
                  Transform Markets
                </span>
              </h1>
              <p className="text-xl text-gray-600">
                From academic research to revolutionary platform, discover how we're changing the future of commodity trading.
              </p>
            </div>

            <div className="relative mt-16">
              {/* Timeline Line */}
              <div className="absolute left-1/2 transform -translate-x-px h-full w-0.5 bg-gradient-to-b from-teal-500 to-emerald-500" />
              
              <div className="space-y-12">
                {timeline.map((event, index) => (
                  <div key={index} className={cn(
                    "relative flex items-center gap-8",
                    index % 2 === 0 ? "flex-row" : "flex-row-reverse"
                  )}>
                    {/* Content */}
                    <div className="flex-1">
                      <div className={cn(
                        "bg-white p-6 rounded-xl shadow-sm border border-neutral-200/80 transition-all duration-300 hover:shadow-md hover:border-neutral-300",
                        index % 2 === 0 ? "mr-4" : "ml-4"
                      )}>
                        <span className="text-sm font-bold text-teal-600">{event.year}</span>
                        <h3 className="text-lg font-semibold mt-1">{event.title}</h3>
                        <div className="text-gray-600 mt-2">{event.description}</div>
                      </div>
                    </div>

                    {/* Timeline Dot */}
                    <div className="absolute left-1/2 transform -translate-x-1/2 flex flex-col items-center">
                      <div className="w-4 h-4 rounded-full bg-gradient-to-r from-teal-500 to-emerald-500" />
                    </div>

                    {/* Empty Space */}
                    <div className="flex-1" />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Values Section */}
        <div className="py-12 md:py-24">
          <div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold">Our Values</h2>
              <p className="mt-4 text-lg text-gray-600">The principles that guide everything we do</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {values.map((value, index) => {
                const Icon = value.icon;
                return (
                  <div key={index} className="relative group">
                    <div className="bg-white rounded-xl p-8 shadow-sm border border-neutral-200 transition-all duration-300 hover:shadow-md hover:border-neutral-300">
                      {/* Icon */}
                      <div className="relative mb-6">
                        <div className="relative bg-gradient-to-br from-teal-50 to-emerald-50/50 rounded-xl border border-teal-100 p-4 shadow-sm">
                          <Icon className="h-6 w-6 text-teal-600" />
                        </div>
                      </div>

                      {/* Content */}
                      <h3 className="text-xl font-semibold mb-3">{value.title}</h3>
                      <p className="text-gray-600">{value.description}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Team Section */}
        <div className="py-12 md:py-24 bg-gray-50">
          <div className="max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold">Our Team</h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              {team.map((member, index) => (
                <div key={index} className="bg-white rounded-xl p-6 shadow-sm border border-neutral-200 transition-all duration-300 hover:shadow-md hover:border-neutral-300">
                  {/* Image */}
                  <div className="relative mx-auto w-24 h-24 mb-6">
                    <img
                      src={member.image}
                      alt={member.name}
                      className="rounded-full w-24 h-24 object-cover border-2 border-white shadow-sm"
                    />
                  </div>

                  {/* Content */}
                  <div className="text-center">
                    <h3 className="font-semibold text-gray-900">{member.name}</h3>
                    <p className="text-sm font-medium text-teal-600 mt-1">{member.role}</p>
                    <p className="text-sm text-gray-600 mt-3">{member.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </main>

      <Footer />
      <SporaChat />
    </div>
  );
}

export default StoryPage;