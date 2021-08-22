/*
 * FileName:      DataBase.cs
 * Author:        天璇
 * Date:          2021/01/01 17:12:16
 * UnityVersion:  2019.4.0f1
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Xml;

namespace EquipmentData
{
    public class DataBase
    {
        private int atk = 0;
        private int def = 0;
        public int ATK { get => atk; }
        public int DEF { get => def; }

        private readonly string weponDataBaseFileName = "Weapon";

        public DataBase(string _weaponName)
        {
            ReadXml(_weaponName);
        }

        private void ReadXml(string _weaponName)
        {
            TextAsset xmlAsset = Resources.Load(weponDataBaseFileName) as TextAsset;
            if (xmlAsset)//文件存在
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(xmlAsset.text);

                //XmlNode root = xmlDoc.FirstChild;
                XmlNode root = xmlDoc.SelectSingleNode("root");
                foreach (XmlElement element in root.ChildNodes)
                {
                    if (element.Name == _weaponName)
                    {
                        atk = int.Parse(element.GetAttribute("ATK"));
                        def = int.Parse(element.GetAttribute("DEF"));
                    }
                }
            }
            else
                Debug.LogError("文件不存在！");
        }
    }
}