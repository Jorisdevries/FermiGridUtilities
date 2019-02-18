#!/bin/env python

import samweb_cli
import argparse
from ROOT import TFile,TTree

def getPOT(file_list,failed_list):
    totpot=0
    for f in file_list:
        is_on_disk=False
        path=""
        pot=0
        for m in samweb.locateFile(f):
            #print m
            if m['location_type']=='disk':
                is_on_disk=True
                path=m['location']

        is_on_disk=True
        path=m['full_path']
        if is_on_disk:
            path=path.replace("enstore:/pnfs","root://fndca1.fnal.gov:1094/pnfs/fnal.gov/usr")+"/"+f
            #print "Open file %s"%path
            try:
                froot=TFile.Open(path)
                ftree=froot.Get("SubRuns")
            except:
                print "Failed to open file %s and get SubRuns tree"%f
                failed_list.append(f)
                continue

            for ientry in range(0, ftree.GetEntries()):
                ftree.GetEntry(ientry)
                found_gen=False
                for k in ftree.GetListOfBranches():
                    if "generator" in k.GetName():
                        if found_gen:
                            print "Found more than one generator???"
                        else:
                            found_gen=True
                            pot+=ftree.GetLeaf("%sobj.totpot"%(k.GetName())).GetValue()
                        
            print f,pot
            totpot+=pot
        else:
            print "File not on disk %s"%f

    return totpot

parser = argparse.ArgumentParser(description='Run info.',formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument("-d", "--defname", type=str,
                    help="SAM definition.")
parser.add_argument("-f", "--filename", type=str,
                    help="File Name.")

args = parser.parse_args()

samweb = samweb_cli.SAMWebClient(experiment='uboone')
flist=[]
if (args.defname):
    flist=samweb.listFiles(defname=args.defname)
else:
    flist.append(args.filename)

failed=[]
ntry=0
sumpot=0

while (len(flist)>0):
    sumpot+=getPOT(flist,failed)
    flist=failed
    if (ntry>10):
        break
    failed=[]
    ntry+=1

if (len(failed)>0):
    print "Tried getting files %i times. Gave up on these files:"%ntry
    print failed

print "Total summed POT: %g"%sumpot

