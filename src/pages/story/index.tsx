"relative flex items-center gap-8",
                    index % 2 === 0 ? "flex-row" : "flex-row-reverse"
                  )}>
                    {/* Content */}
                    <div className="flex-1">
                      <div className={cn(
                        "bg-white p-6 rounded-lg shadow-md transition-all duration-300 hover:shadow-lg",
                        index % 2 === 0 ? "mr-4" : "ml-4"
                      )}>
                        <span className="text-sm font-bold text-teal-600">{event.year}</span>
                        <h3 className="text-lg font-semibold mt-1">{event.title}</h3>
                        <p className="text-gray-600 mt-2">{event.description}</p>
                      </div>
                    </div>

                    {/* Timeline Dot */}
                    <div className="absolute left-1/2 transform -translate-x-1/2 w-4 h-4 rounded-full bg-gradient-to-r from-teal-500 to-emerald-500" />

                    {/* Empty Space */}
                    <div className="flex-1" />
                  </div>
                ))}
              </div>
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