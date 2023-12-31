#include <omnetpp.h>
#include "Mail_m.h"

using namespace omnetpp;


class Source : public cSimpleModule
{
  private:
    cMessage *sendMessageEvent;
    int nbGenMessages;

    double avgInterArrivalTime;
    double start_uniform;
    double end_uniform;

    simsignal_t plenSignal;

  public:
    Source();
    virtual ~Source();

  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
};

Define_Module(Source);

Source::Source()
{
    sendMessageEvent = nullptr;

}

Source::~Source()
{
    cancelAndDelete(sendMessageEvent);
}

void Source::initialize()
{

    plenSignal = registerSignal("plen");

    sendMessageEvent = new cMessage("sendMessageEvent");
    nbGenMessages = 0;

    // default values
    start_uniform = 0;


    //get avg interarrival time
    avgInterArrivalTime = par("avgInterArrivalTime").doubleValue();

    //get uniform distirbution range

    end_uniform = par("end_uniform").doubleValue();


    EV << "starting simulation wiith:" << endl;
    EV << " lambda = " << 1/avgInterArrivalTime << endl;
    EV << "G is Uniform(0," << end_uniform << ")" << endl;

    //start sending packets
    scheduleAt(simTime(), sendMessageEvent);
}

void Source::handleMessage(cMessage *msg)
{
    //generate packet name
    char msgname[20];
    sprintf(msgname, "%d", ++nbGenMessages);

    //generate and send the packet out to the queue
    Mail* mail = new Mail(msgname);

    // attach to the mail it's process time
    double service_time = uniform(start_uniform, end_uniform);

    emit(plenSignal, (simtime_t)service_time);

    mail->setService_time(service_time);

    EV  << "scheduling new pachet " << mail->getName()
        << " with service time of " << mail->getService_time() << " s." << endl;

    send(mail, "out");

    //schedule next packet
    scheduleAt(simTime()+exponential(avgInterArrivalTime), sendMessageEvent);
}
